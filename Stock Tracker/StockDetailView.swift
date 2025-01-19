import SwiftUI

struct StockDetailView: View {
    let stockSymbol: String
    @State private var stockData: Stock?
    
    // For now, let's just use some dummy data for the graph
    let dummyData = Array(repeating: Double.random(in: 100...200), count: 0)
    
    var body: some View {
        VStack {
            if let stock = stockData {
                Text(stock.ticker)
                    .font(.largeTitle)
                    .padding()

                // Display the stock's price and other details here if you'd like
                Text("Price: \(stock.price)")
                    .font(.title2)
                
                // Display the change in stock price
                Text("Change: \(stock.change)")
                    .font(.subheadline)
                
                // Graph View with the dummy data
                GraphView(data: dummyData)
            } else {
                Text("Loading...")
                    .onAppear {
                        fetchStockDetails(for: stockSymbol)
                    }
            }
        }
        .padding()
    }

    func fetchStockDetails(for symbol: String) {
        let networkManager = NetworkManager()
        networkManager.fetchStockDetails(ticker: symbol) { stock in
            if let stock = stock {
                DispatchQueue.main.async {
                    self.stockData = stock
                }
            }
        }
    }
}

struct StockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StockDetailView(stockSymbol: "AAPL")
    }
}
