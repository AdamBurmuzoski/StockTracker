import SwiftUI

struct StocksView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    func deleteStock(at offsets: IndexSet) {
        viewModel.searchResults.remove(atOffsets: offsets)
        viewModel.saveStocks()
    }
    
    func moveStock(from source: IndexSet, to destination: Int) {
        viewModel.searchResults.move(fromOffsets: source, toOffset: destination)
        viewModel.saveStocks()
    }

    var body: some View {
        ZStack {
            // Invisible rectangle to capture taps not handled by other views
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack {
                TextField("Search...", text: $viewModel.searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8.0)
                    .padding(.horizontal)
                
                Text("Search Results")
                    .font(.headline)
                    .padding(.top)
                
                List(viewModel.tickerSuggestions) { symbol in
                    Button(action: {
                        viewModel.toggleFavorite(symbol: symbol.symbol)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }) {
                        HStack {
                            Text("\(symbol.symbol): \(symbol.name)")
                                .font(.footnote)
                            Spacer()
                            if viewModel.isFavorited(symbol: symbol.symbol) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .listRowBackground(viewModel.isFavorited(symbol: symbol.symbol) ? Color.green.opacity(0.2) : Color.clear)
                }

                Text("API Requests limited to 5 per minute.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct StocksView_Previews: PreviewProvider {
    static var previews: some View {
        StocksView()
    }
}
