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

class NetworkManager {
    let apiKey = "NMF9FQVMB00PZOY4"
    let baseURL = "https://www.alphavantage.co/query?"

    func fetchStockDetails(ticker: String, completion: @escaping (Stock?) -> Void) {
        let urlString = "\(baseURL)function=GLOBAL_QUOTE&symbol=\(ticker)&apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(StockResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(decodedResponse.stock)
                    }
                } catch {
                    print("Decoding error: ", error)
                }
            } else if let error = error {
                print("Fetch error: ", error)
            }
        }
        
        task.resume()
    }
    
    func searchSymbols(searchText: String, completion: @escaping ([SymbolSearchResult]?) -> Void) {
        let urlString = "\(baseURL)function=SYMBOL_SEARCH&keywords=\(searchText)&apikey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(SymbolSearchResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(decodedResponse.bestMatches)
                    }
                } catch {
                    print("Decoding error: ", error)
                }
            } else if let error = error {
                print("Fetch error: ", error)
            }
        }

        task.resume()
    }
}

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var tickerSuggestions: [SymbolSearchResult] = []
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
                self?.searchSymbols(searchText: searchText)
            }

        loadSavedStocks()
    }
    
    func searchSymbols(searchText: String) {
        networkManager.searchSymbols(searchText: searchText) { symbols in
            self.tickerSuggestions = symbols ?? []
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




struct StockDetailView: View {
    let stock: Stock
    // For now, let's just use some dummy data for the graph
    let dummyData = Array(repeating: Double.random(in: 100...200), count: 30)

    var body: some View {
        VStack {
            Text(stock.ticker)
            GraphView(data: dummyData)
        }
    }
}

struct StockRowView: View {
    let stock: Stock
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(stock.ticker)
                    .font(.headline)
                    
                Spacer()
                Text("\(stock.price)")
                    
                    .font(.subheadline)
            }
            HStack {
                Text("Change:")
                Text("\(stock.change)")
                    .foregroundColor(Double(stock.change) ?? 0 > 0 ? .green : .red)
                    .font(.subheadline)
                Spacer()
                Text("")
                Text("\(stock.changePercent)")
                    .foregroundColor(stock.changePercent.contains("-") ? .red : .green)
                    .font(.subheadline)
            }
        }
        .padding(.horizontal) // Remove vertical padding to make the row smaller
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

// GraphView struct
struct GraphView: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            let graphHeight = geometry.size.height
            let graphWidth = geometry.size.width
            let maxValue = self.data.max() ?? 0
            let minValue = self.data.min() ?? 0
            let verticalScale = graphHeight / CGFloat(maxValue - minValue)
            let horizontalScale = graphWidth / CGFloat(self.data.count - 1)
            
            Path { path in
                for i in self.data.indices {
                    let x = CGFloat(i) * horizontalScale
                    let y = CGFloat(self.data[i] - minValue) * verticalScale
                    let point = CGPoint(x: x, y: graphHeight - y)
                    
                    if i == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
            }
            .stroke(Color.blue)
        }
    }
}
