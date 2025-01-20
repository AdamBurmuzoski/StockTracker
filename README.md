# Stock Tracker App

A SwiftUI-based iOS app that allows users to search for stock symbols, view stock details, and track their favorite stocks. The app fetches data using the Alpha Vantage API and provides features for stock search, displaying real-time stock prices, and managing a list of favorite stocks.

---

## Features

- **Search for Stocks**  
  Search for stock symbols by keyword or name using the Alpha Vantage API.

- **View Stock Details**  
  Displays key information about a stock, including its current price, daily change, and percentage change.

- **Favorites**  
  Add or remove stocks from the favorites list, which will be saved locally for easy access later.

- **Keyboard Awareness**  
  The app adjusts the layout to prevent UI elements from being covered by the keyboard while typing.

- **Offline Support**  
  Stock data is saved locally using **UserDefaults** and can be reloaded when the app is reopened.

- **Refresh Stocks**  
  Refresh the stock data for all favorite stocks with a button press. (Due to the limited 5 API calls per minute on the free Alpha Vantage API key, auto-refresh is not enabled by default.)

---

## Dependencies

- **SwiftUI**: For building the user interface.
- **Alpha Vantage API**: For fetching real-time stock data.
- **UserDefaults**: For storing and retrieving the list of favorite stocks.

---

## How to Run

1. Clone or download the repository.
2. Open the project in **Xcode**.
3. Run the app on a simulator or a physical device.
4. Start searching for stock symbols, view stock details, and add stocks to your favorites list.
