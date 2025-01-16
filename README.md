A SwiftUI-based iOS app that allows users to search for stock symbols, view stock details, and track their favorite stocks. 
The app fetches data using the Alpha Vantage API and provides features for stock search, displaying real-time stock prices, and managing a list of favorite stocks.

Features:
Search for Stocks: Search for stock symbols by keyword or name using the Alpha Vantage API.
View Stock Details: Displays key information about a stock, including its current price, daily change, and percentage change.
Favorites: Add/remove stocks from the favorites list, which will be saved locally for easy access later.
Keyboard Awareness: The app adjusts the layout to avoid UI elements being covered by the keyboard while typing.
Offline Support: Stock data is saved locally using UserDefaults and can be reloaded when the app is reopened.
Refresh Stocks: Refresh the stock data for all favorites with a button press. (Due to limited 5 API calls per minute on free Alpha Vantage API key, otherwise auto-refresh would be default).
