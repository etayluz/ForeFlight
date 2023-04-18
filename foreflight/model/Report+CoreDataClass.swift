//
//  Report+CoreDataClass.swift
//  foreflight
//
//  Created by Etay Luz on 4/18/23.
//
//

import Foundation
import CoreData

@objc(Report)
public class Report: NSManagedObject {
    
    func parseJson(_ json: [String: Any]) {
        if let reportJson = json["report"] as? JSONDictionary {
            // print(report)
            if let conditions = reportJson["conditions"] as? JSONDictionary {
                // print(conditions)
                let jsonData = try? JSONSerialization.data(withJSONObject: conditions, options: [])
                if let jsonString = String(data: jsonData!, encoding: .utf8) {
                    self.conditions = jsonString
                }
            }
            if let forecast = reportJson["forecast"] as? JSONDictionary {
                // print(forecast)
                let jsonData = try? JSONSerialization.data(withJSONObject: forecast, options: [])
                if let jsonString = String(data: jsonData!, encoding: .utf8) {
                    self.forecast = jsonString
                }
            }
        }
    }

}
