import Foundation

struct WeatherData: Codable {
    let current: CurrentWeather
}

struct CurrentWeather: Codable {
    let condition: Condition
}

struct Condition: Codable {
    let text: String
}

