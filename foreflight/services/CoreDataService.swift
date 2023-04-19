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
    
//    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let persistentStoreCoordinator = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.persistentStoreCoordinator
    var reports: [Report]? // data for the table
    
    func fetchReports() async -> [Report] {
        
//         clearReports() // COMMENT ME OUT - ONLY USE DURING DEVELOPMENT
        // Fetch the data from Core Data to display in the tableView
        do {
            self.reports = try context.fetch(Report.fetchRequest())
        }
        catch {
            
        }
        
        return self.reports!
    }
    
    // This is a helper function to clear reports - used during development
    func clearReports() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Report")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentStoreCoordinator.execute(deleteRequest, with: context)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func reportFromJson(_ airport: String, _ json: [String: Any]) -> Report {
        // Delete existing report for airport
        context.performAndWait {
            do {
                deleteReport(airport: airport)
                try self.context.save()
            }
            catch {
                
            }
        }
        
        let report = Report(context:context)
        report.airport = airport
        report.parseJson(json)
        
        return report
    }
    
    func saveReport(newReport: Report) async {
        // Delete any previous reports for this airport
        let reports1 = await self.fetchReports()
        print(reports1)
        
        
        let reports2 = await self.fetchReports()
        print(reports2)

    }

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
