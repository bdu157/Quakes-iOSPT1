//
//  QuakeFetcher.swift
//  Quakes (iOSPT1)
//
//  Created by Dongwoo Pae on 9/26/19.
//  Copyright © 2019 Dongwoo Pae. All rights reserved.
//

import Foundation

//to access from QuakeFetcher
extension CoordinateRegion {
    fileprivate var queryItems: [URLQueryItem] {
        return [
            URLQueryItem(name: "minlongitude", value: String(origin.longitude)),
            URLQueryItem(name: "minlatitude", value: String(origin.latitude)),
            URLQueryItem(name: "maxlongitude", value: String(origin.longitude + size.width)),
            URLQueryItem(name: "maxlatitude", value: String(origin.latitude + size.height))
        ]
    }
}

class QuakeFether {
    
    enum FetcherError: Int, Error {
        case unknownError
        case dateMathError
        case invalidURL
    }
    //dateCalendar and dateinterval

    //MARK PROPERTIES
    static let baseURL = URL(string: "https://earthquake.usgs.gov/fdsnws/event/1/query")!
    private let dateFormatter = ISO8601DateFormatter()   //currently it is all number
    
    
    //wrapper method to just take the date and go back to one week
    func fetchQuakes(in region: CoordinateRegion? = nil, completion:@escaping ([Quake]?, Error?) -> Void) {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        var components = DateComponents()
        components.calendar = calendar
        components.day = -7
        
        guard let aWeekAgo = calendar.date(byAdding: components, to: now) else {
            completion(nil, FetcherError.dateMathError)
            return
        }
        let today = DateInterval(start: aWeekAgo, end: now)
        self.fetchQuakes(in: region, inDateInterval: today, completion: completion)
    }
    
    
    func fetchQuakes(in region: CoordinateRegion? = nil, inDateInterval: DateInterval, completion: @escaping ([Quake]?, Error?) -> Void) {
        
        var urlComponents = URLComponents(url: QuakeFether.baseURL, resolvingAgainstBaseURL: true)!
        let startDate = dateFormatter.string(from: inDateInterval.start)
        let endDate = dateFormatter.string(from: inDateInterval.end)
        
        var queryItems = [URLQueryItem(name: "format", value: "geojson"),
                          URLQueryItem(name: "starttime", value: startDate),
                          URLQueryItem(name: "endtime", value: endDate)]
        
        if let region = region {
            queryItems.append(contentsOf: region.queryItems)
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            completion(nil, FetcherError.invalidURL)
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, FetcherError.unknownError)
                return
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
            
            do {
                let quakes = try jsonDecoder.decode(QuakeResults.self, from: data).features
                completion(quakes, nil)
            } catch {
                completion(nil, error)
                return
            }
        }.resume()
    }
}


//being able to create mapView
//being able to coordinate system
//being able to create annotationView (tableView cell) and callout
//coordinate Region
