import Combine
import SwiftUI
import Foundation

@main
struct StockTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            
            ContentView()
        }
    }
}



class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var tickerSuggestions: [SymbolSearchResult] = []  // Correct type
    @Published var lastUpdated = Date()

    @Published var searchResults = [Stock]()

    func isFavorited(symbol: String) -> Bool {
        return searchResults.contains(where: { $0.ticker == symbol })
    }

    func toggleFavorite(symbol: String) {
        if let index = searchResults.firstIndex(where: { $0.ticker == symbol }) {
            // If the stock is already favorited, remove it
            searchResults.remove(at: index)
            saveStocks()
        } else {
            // Otherwise, add it to the favorites list
            networkManager.fetchStockDetails(ticker: symbol) { [weak self] stock in
                guard let self = self else { return }
                if let stock = stock {
                    DispatchQueue.main.async {
                        self.searchResults.append(stock)
                        self.saveStocks()
                    }
                }
            }
        }
    }

    let networkManager = NetworkManager()
    private var anyCancellable: AnyCancellable?

    init() {
        anyCancellable = $searchText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.searchSymbols(query: searchText)  // Correct method signature
            }

        loadSavedStocks()
    }

    func searchSymbols(query: String) {
        networkManager.searchSymbols(query: query) { [weak self] symbols in
            // Ensure symbols is of type [SymbolSearchResult]
            self?.tickerSuggestions = symbols ?? []
        }
    }

    func saveStocks() {
        do {
            let data = try JSONEncoder().encode(self.searchResults)
            UserDefaults.standard.set(data, forKey: "stocks")
        } catch {
            print("Save failed: ", error)
        }
    }

    func loadSavedStocks() {
        do {
            if let data = UserDefaults.standard.data(forKey: "stocks") {
                self.searchResults = try JSONDecoder().decode([Stock].self, from: data)
            }
        } catch {
            print("Load failed: ", error)
        }
    }

    func refreshStocks() {
        let dispatchGroup = DispatchGroup()

        for i in 0..<searchResults.count {
            dispatchGroup.enter()
            let ticker = searchResults[i].ticker
            networkManager.fetchStockDetails(ticker: ticker) { stock in
                if let stock = stock {
                    DispatchQueue.main.async {
                        self.searchResults[i] = stock
                    }
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.saveStocks()
        }
    }
}

struct KeyboardAwareModifier: ViewModifier {
    @StateObject private var viewModel = SearchViewModel()
    @State private var keyboardHeight: CGFloat = 0

    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onAppear(perform: addKeyboardObservers)
            .onDisappear(perform: removeKeyboardObservers)
    }

    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
            let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            keyboardHeight = keyboardSize?.height ?? 0
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }

    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension View {
    func keyboardAwarePadding() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAwareModifier())
    }
}




struct Stock: Identifiable, Codable {
    var id: String { ticker }
    let ticker: String
    let price: String
    let change: String
    let changePercent: String

    enum CodingKeys: String, CodingKey {
        case ticker = "01. symbol"
        case price = "05. price"
        case change = "09. change"
        case changePercent = "10. change percent"
    }
}

struct StockResponse: Codable {
    let stock: Stock

    enum CodingKeys: String, CodingKey {
        case stock = "Global Quote"
    }
}

// For symbol search
struct SymbolSearchResult: Identifiable, Codable {
    var id: String { symbol }
    let symbol: String
    let name: String
    var isFavorite: Bool = false

    enum CodingKeys: String, CodingKey {
        case symbol = "1. symbol"
        case name = "2. name"
    }
}


struct SymbolSearchResponse: Codable {
    let bestMatches: [SymbolSearchResult]

    enum CodingKeys: String, CodingKey {
        case bestMatches = "bestMatches"
    }
}



