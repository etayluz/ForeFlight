//
//  Report+CoreDataProperties.swift
//  foreflight
//
//  Created by Etay Luz on 4/18/23.
//
//

import Foundation
import CoreData


extension Report {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Report> {
        return NSFetchRequest<Report>(entityName: "Report")
    }

    @NSManaged public var airport: String?
    @NSManaged public var conditions: String?
    @NSManaged public var forecast: String?

}

extension Report : Identifiable {

}
