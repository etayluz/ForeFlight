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
    
    func getReport(airport: String) async -> Report? {
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
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
            //                    print(dictionary!)
            if dictionary!["error"] != nil {
                print("Invalid airport: " + airport)
                return nil
                
            } else {
                guard let dictionary = dictionary else {
                    print("Error with data")
                    return nil
                }
            }
        }
        catch {
            
        }
        return nil
    }
}


//                        let newReport = Report(context: self.context)
//                        newReport.airport = airport
//
//                        if let report = dictionary["report"] as? JSONDictionary {
//                //            print(report)
//                            if let conditions = report["conditions"] as? JSONDictionary {
//                //                print(conditions)
//                                let jsonData = try? JSONSerialization.data(withJSONObject: conditions, options: [])
//                                if let jsonString = String(data: jsonData!, encoding: .utf8) {
//                                    newReport.conditions = jsonString
//                                }
//                            }
//                            if let forecast = report["forecast"] as? JSONDictionary {
//                //                print(forecast)
//                                let jsonData = try? JSONSerialization.data(withJSONObject: forecast, options: [])
//                                if let jsonString = String(data: jsonData!, encoding: .utf8) {
//                                    newReport.forecast = jsonString
//                                }
//                            }
//                        }
                        
                        // Save the data
//                        do {
//                            try self.context.save()
//                        }
//                        catch {
//
//                        }
                        
                        // Re-fetch the data
//                        self.fetchReports()
                        
//                        DispatchQueue.main.async {
//                            if !self.airports.contains(airport) {
//                                self.airports.append(airport)
//                                self.tableView.reloadData()
//                            }
//
//                            self.performSegue(withIdentifier: "WeatherReportSegue", sender: nil)

//                        DispatchQueue.main.async {
////                            self.searchTextField.text?.removeAll()
//                            self.presentInvalidAirportAlert(airport: airport)
//                        }
