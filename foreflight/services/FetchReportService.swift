//
//  FetchReportService.swift
//  foreflight
//
//  Created by Etay Luz on 4/18/23.
//

import Foundation

class FetchReportService {
    
    var coreDataService: CoreDataService!
    
    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
    }
    
    func getReport(airport: String) async -> [String: Any]? {
        print(airport)
        // URL
        let url = URL(string: "https://qa.foreflight.com/weather/report/" + airport)
        
        guard url != nil else {
            print("Error creating URL object")
            return nil
        }
        
        // HRL Request
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        // Specify the headers
        let headers = ["ff-coding-exercise": "1"]
        request.allHTTPHeaderFields = headers
        
        // Set the request type
        request.httpMethod = "GET"
        
        // Get the URLSession
        let session = URLSession.shared

        // Create the data task
        do {
            let (data, _) = try await session.data(for: request)
            
            // Try to parse out the data
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
            //                    print(dictionary!)
            if json!["error"] != nil {
                print("Invalid airport: " + airport)
                return nil
                
            } else {
                guard let json = json else {
                    print("Error with data")
                    return nil
                }
                return json
            }
        }
        catch {
            
        }
        return nil
    }
}
