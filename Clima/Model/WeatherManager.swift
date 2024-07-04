//
//  WeatherManager.swift
//  Clima
//
//  Created by Raghavendra Mirajkar on 03/07/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ Error: Error)
}

enum NetworkError : Error {
    case badResponse
    case invalidURL
    case badRequest
}

struct WeatherManager {
    
    var delegate : WeatherManagerDelegate?
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=23f9af54bc286d422c0e7b977f3ea33b&units=metric"
    
    func fetchWeather(cityName: String) {
        let url = "\(weatherURL)&q=\(cityName)"
        performRequest(url)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let url = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(url)
    }
    
    func performRequest(_ url: String) {
        guard let url = URL(string: url) else {
                print("Invalid URL.")
                return
            }

            // 2. Create a URLSession
            let session = URLSession(configuration: .default)

            // 3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    delegate?.didFailWithError(error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    print("Server error.")
                    return
                }

                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            // 4. Start the task
            task.resume()
    }
    
    func parseJSON(_ data: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodeData = try decoder.decode(WeatherResponse.self, from: data)
            let temp = decodeData.main.temp
            let id = decodeData.weather[0].id
            let city = decodeData.name
            let weather = WeatherModel(conditionId: id, cityName: city, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
}


