//
//  WeatherReportVC.swift
//  foreflight
//
//  Created by Etay Luz on 4/17/23.
//

import UIKit
typealias JSONDictionary = [String:Any]

class WeatherReportVC: UIViewController {

    @IBOutlet weak var contentSwitch: UISwitch!
    @IBOutlet weak var reportTextView: UITextView!
    var reportDic = [String: Any]()
    var conditionsString = ""
    var forcastString = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        if let report = reportDic["report"] as? JSONDictionary {
//            print(report)
            if let conditions = report["conditions"] as? JSONDictionary {
//                print(conditions)
                let jsonData = try? JSONSerialization.data(withJSONObject: conditions, options: [])
                if let jsonString = String(data: jsonData!, encoding: .utf8) {
                    conditionsString = jsonString
                }
            }
            if let forecast = report["forecast"] as? JSONDictionary {
//                print(forecast)
                let jsonData = try? JSONSerialization.data(withJSONObject: forecast, options: [])
                if let jsonString = String(data: jsonData!, encoding: .utf8) {
                    forcastString = jsonString
                }
            }
        }
        
        reportTextView.text = conditionsString
    }


    
    @IBAction func didToggleSwitch(_ sender: Any) {
        if self.contentSwitch.isOn {
            reportTextView.text = conditionsString
        } else {
            reportTextView.text = forcastString
        }
    }
    
}
