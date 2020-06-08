//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(erorr: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    /* The API Key I received didn't work, so for testing purposes I am using some random person's API Key. */
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    // let apiKey = "4A8F38C8-76E2-4453-987F-5FE095105885"
    let apiKey = "F19C1290-59A9-4775-BD10-08A5E14DDA93"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String) {
        let URLString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        if let url = URL(string: URLString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if error != nil {
                    self.delegate?.didFailWithError(erorr: error!)
                    return
                }
                
                if let safeData = data {
                    
                    if let bitcoinPrice = self.parseJSON(safeData) {
                        let bitcoinString = String(format: "%.2f", bitcoinPrice)
                        self.delegate?.didUpdatePrice(price: bitcoinString, currency: currency)
                    }
                    
                }
                
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            
            let lastPrice = decodedData.rate
            
            print(lastPrice)
            return lastPrice
            
        } catch {
            print("localized description: \(error.localizedDescription)")
            delegate?.didFailWithError(erorr: error)
            return nil
        }
        
    }
    
    
}
