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
    var airport = ""
    var conditions = ""
    var forecast = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        reportTextView.text = conditions
    }


    
    @IBAction func didToggleSwitch(_ sender: Any) {
        if self.contentSwitch.isOn {
            reportTextView.text = conditions
        } else {
            reportTextView.text = forecast
        }
    }
    
}
