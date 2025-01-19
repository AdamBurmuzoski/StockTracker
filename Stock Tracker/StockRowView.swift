import SwiftUI

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
