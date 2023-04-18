//
//  WeatherReportVC.swift
//  foreflight
//
//  Created by Etay Luz on 4/17/23.
//

import UIKit
typealias JSONDictionary = [String:Any]

class WeatherReportVC: UIViewController {

    @IBOutlet weak var reportTextView: UITextView!
    var reportDic = [String: Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let report = reportDic["report"] as? JSONDictionary {
//            print(report)
            if let conditions = report["conditions"] as? JSONDictionary {
                print(conditions)
                let jsonData = try? JSONSerialization.data(withJSONObject: conditions, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)
                reportTextView.text = jsonString
            }
        }
            
        
    }
}
