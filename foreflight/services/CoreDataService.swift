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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let persistentStoreCoordinator = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.persistentStoreCoordinator
    var reports: [Report]? // data for the table
    
    func fetchReports() async -> [Report] {
        
        clearReports() // COMMENT ME OUT - ONLY USE DURING DEVELOPMENT
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

}
