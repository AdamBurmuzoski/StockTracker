import Foundation

// Define the TimeSeriesResponse struct
struct TimeSeriesResponse: Codable {
    let timeSeries: [TimeSeriesData]

    enum CodingKeys: String, CodingKey {
        case timeSeries = "Time Series (Daily)" // This is the key used by the API
    }
}

// Define the TimeSeriesData struct to represent each day's data
struct TimeSeriesData: Codable {
    let date: String
    let close: String  // Closing price for the day

    enum CodingKeys: String, CodingKey {
        case date = "date"       // Date is the key for each entry's date
        case close = "4. close"  // Alpha Vantage returns closing price under "4. close"
    }
}

class NetworkManager {
    let apiKey = ""
    let baseURL = "https://www.alphavantage.co/query?"
    
    // Fetch stock details (already defined)
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
    
    // Fetch historical data (new method)
    func fetchHistoricalData(ticker: String, completion: @escaping ([Double]?) -> Void) {
        let urlString = "\(baseURL)function=TIME_SERIES_DAILY&symbol=\(ticker)&apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for historical data")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    // Decode the time series response
                    let decodedResponse = try JSONDecoder().decode(TimeSeriesResponse.self, from: data)
                    // Extract the closing prices into an array
                    let closingPrices = decodedResponse.timeSeries.map { Double($0.close) ?? 0.0 }
                    DispatchQueue.main.async {
                        completion(closingPrices)
                    }
                } catch {
                    print("Decoding error for historical data: ", error)
                }
            } else if let error = error {
                print("Fetch error for historical data: ", error)
            }
        }
        
        task.resume()
    }
    func searchSymbols(query: String, completion: @escaping ([SymbolSearchResult]?) -> Void) {
        let urlString = "\(baseURL)function=SYMBOL_SEARCH&keywords=\(query)&apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for symbol search")
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

