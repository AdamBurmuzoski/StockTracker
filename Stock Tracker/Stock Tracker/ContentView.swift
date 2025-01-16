//
//  ContentView.swift
//  Stock Tracker
//
//  Created by Adam Burmuzoski on 6/30/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        TabView {
            FavoritesView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Favorites")
                }

            StocksView()
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    Text("Stocks")
                }

            CryptoView()
                .tabItem {
                    Image(systemName: "bitcoinsign.circle")
                    Text("Crypto")
                }
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
