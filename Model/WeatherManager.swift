//
//  WeatherManager.swift
//  WeatherChecker
//
//  Created by apat on 3/13/25.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "ADD API KEY HERE"
    
    var delegate: WeatherManagerDelegate?
    
    
    func fetchWeather(cityName: String) {
            let urlString = "\(weatherURL)&q=\(cityName)"
            performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
            let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
            performRequest(with: urlString)
        }
    
    
    func performRequest(with urlString: String) {
        
        if let url = URL(string: urlString) { // Create a URL
        let session = URLSession(configuration: .default) // Create a URLSession
            let task = session.dataTask(with: url) { (data, response, error) in  // Give the session a task
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            // Start the task
            task.resume()
            
        }
        
        func parseJSON(_ weatherData: Data) -> WeatherModel? {
            let decoder = JSONDecoder()
            
            do {
                let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
                let id = decodedData.weather[0].id
                let temp = decodedData.main.temp
                let name = decodedData.name
                
                let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
                    return weather

            } catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
        
        
        
    }
    
    }
