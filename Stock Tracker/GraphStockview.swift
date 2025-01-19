import SwiftUI

struct GraphStockView: View {
    let stockSymbol: String  // Ticker symbol (String) instead of a Stock object
    @State private var historicalData: [Double] = []
    
    let networkManager = NetworkManager()
    
    var body: some View {
        VStack {
            Text(stockSymbol)
                .font(.largeTitle)
                .padding()
            
            Button("Load Historical Data") {
                loadData()
            }

            GraphView(data: historicalData)
                .padding()
        }
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        networkManager.fetchHistoricalData(ticker: stockSymbol) { prices in
            if let prices = prices {
                // Use the fetched historical data (closing prices)
                self.historicalData = prices
                // Log the response for debugging purposes
                print("Fetched historical data: \(self.historicalData)")
            }
        }
    }
}

struct GraphView: View {
    let data: [Double]

    var body: some View {
        VStack {
            Text("Graph Here")
                .font(.headline)
            // You can implement a custom graph view, for now, just displaying the data in a list
            List(data, id: \.self) { price in
                Text("$\(price, specifier: "%.2f")")
            }
        }
    }
}
