import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    func deleteStock(at offsets: IndexSet) {
        viewModel.searchResults.remove(atOffsets: offsets)
        viewModel.saveStocks()
        viewModel.loadSavedStocks()
    }
    
    func moveStock(from source: IndexSet, to destination: Int) {
        viewModel.searchResults.move(fromOffsets: source, toOffset: destination)
        viewModel.saveStocks()
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.searchResults) { stock in
                    NavigationLink(destination: StockDetailView(stock: stock)) {
                        StockRowView(stock: stock)
                    }
                }
                .onDelete(perform: deleteStock)
                .onMove(perform: moveStock)
            }
            .navigationTitle("Favorites")
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(action: {
                    viewModel.refreshStocks()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            )
            .onAppear {
                viewModel.loadSavedStocks()
            }
        }
    }
}


struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
