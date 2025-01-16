import SwiftUI

struct CryptoView: View {
    @StateObject private var viewModel = CryptoViewModel()
    
    var body: some View {
        VStack {
            Button("Refresh") {
                viewModel.refreshData()
            }
            ForEach(viewModel.cryptoData) { crypto in
                CryptoRowView(crypto: crypto)
            }
            
            .padding()
        }
        .onAppear(perform: viewModel.loadData)
    }
}

struct CryptoRowView: View {
    let crypto: Crypto
    
    var body: some View {
        HStack {
            Image(systemName: crypto.iconName)
                .resizable()
                .frame(width: 30, height: 30)
            Text(crypto.name)
            Spacer()
            Text("$\(String(format: "%.5f", Double(crypto.price) ?? 0))")
                .fixedSize(horizontal: true, vertical: false) // Ensure text doesn't wrap
                .font(Font.system(size: 16, weight: .medium, design: .default))
                .padding(.horizontal, 10)
                .cornerRadius(8)
        }
        .padding()
    }
}


class CryptoViewModel: ObservableObject {
    @Published var cryptoData: [Crypto] = []
    
    private let apiKey = "ACB0AB27-8FAE-45F7-9BE8-3011E07FB218"
    private let baseURL = "https://api.coincap.io/v2/assets"
    private let symbols = ["bitcoin", "ethereum", "tether", "cardano", "dogecoin"]
    
    private var dataLoaded = false
    
    func loadData() {
        guard !dataLoaded else {
            return
        }
        
        for symbol in symbols {
            let urlString = "\(baseURL)?key=\(apiKey)&search=\(symbol)"
            
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                continue
            }
            
            let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(CryptoResponse.self, from: data)
                        if let cryptoData = decodedResponse.data.first {
                            let crypto = Crypto(
                                name: cryptoData.name,
                                price: cryptoData.priceUsd,
                                iconName: cryptoData.symbol.lowercased()
                            )
                            DispatchQueue.main.async {
                                self?.cryptoData.append(crypto)
                            }
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
        
        dataLoaded = true
    }
    
    func refreshData() {
        cryptoData.removeAll()
        dataLoaded = false
        loadData()
    }
}


struct Crypto: Identifiable {
    var id: String { name }
    let name: String
    let price: String
    let iconName: String
}

struct CryptoData: Codable {
    let id: String
    let name: String
    let symbol: String
    let priceUsd: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case priceUsd = "priceUsd"
    }
}

struct CryptoResponse: Codable {
    let data: [CryptoData]
}
