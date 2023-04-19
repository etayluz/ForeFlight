//
//  CoreDataService.swift
//  foreflight
//
//  Created by Etay Luz on 4/18/23.
//

import Foundation
import UIKit
import CoreData

class CoreDataService {
    
    // context and persistentStoreCoordinator are injected during CoreDataService creatin in SceneDelegate.swift
    var context: NSManagedObjectContext!
    var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    /// Fetches all reports from Core Data
    ///
    /// - Returns: Returns all reports from Core Data
    func fetchReports() async -> [Report] {
        
        // clearReports() // COMMENT OUT - ONLY USE DURING DEVELOPMENT to clear all reports
        
        // Fetch the data from Core Data to display in the tableView
        var reports: [Report] = [] // data for the table
        do {
            reports = try context.fetch(Report.fetchRequest())
        }
        catch {
            
        }
        
        return reports
    }
    
    /// A helper function to clear reports from Core Data - used during development
    func clearReports() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Report")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentStoreCoordinator.execute(deleteRequest, with: context)
        } catch let error as NSError {
            print(error)
        }
    }

    /// parse out json for airport report and return NSManagedObject for new airport report
    ///
    /// - Parameters:
    ///     - airport: Airport
    ///     - json: report data
    ///
    /// - Returns: Creates a new Report NSManagedObject  for the given `airport` and json from API.
    func reportFromJson(_ airport: String, _ json: [String: Any]) -> Report {
        // Delete existing report for airport
        deleteReport(airport: airport)

        // Create new report for airport
        let report = Report(context:context)
        report.airport = airport
        report.parseJson(json)
        
        return report
    }
    
    /// Persist context
    ///
    func saveContext() async {
        context.performAndWait {
            do {
                try self.context.save()
            }
            catch {
                
            }
        }
    }

    /// Delete previous report for airport
    ///
    /// - Parameters:
    ///     - airport: The airport to fetch report for
    ///
    func deleteReport(airport: String) {
        let fetchRequest = NSFetchRequest<Report>(entityName: "Report")
        fetchRequest.predicate = NSPredicate(format: "airport = '\(airport)'")

        do {
            let result = try context.fetch(fetchRequest)
            if result.count > 0 {
                let managedObject = result[0]
                context.delete(managedObject)
            }

        } catch let error {
            print(error.localizedDescription)
        }
    }
    

}
