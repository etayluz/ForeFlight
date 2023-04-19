//
//  ViewController.swift
//  foreflight
//
//  Created by Etay Luz on 4/17/23.
//

import UIKit

class AirportListVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!

    var selectedReport: Report?
    var coreDataService: CoreDataService!
    var fetchReportService: FetchReportService!
    var reports: [Report] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getReportsFromCoreData()
        
        // Initially populate airport list with KPWM & KAUS
        if self.reports.count == 0 {
            getReport(airport: "KPWM", shouldShowReport: false)
            getReport(airport: "KAUS", shouldShowReport: false)
        }
        
    }
    
    /// Fetch all reports from core data and reload tableView
    func getReportsFromCoreData() {
        // Get reports from Core Data and refresh tableView
        Task {
            self.reports = await coreDataService.fetchReports()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    

    /// Initialize the Westher Report View Controller with report data conditions and forecast
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WeatherReportSegue" {
            if let weatherReportVC = segue.destination as? WeatherReportVC {
                if let forecast = self.selectedReport?.forecast {
                    weatherReportVC.forecast = forecast
                }
                if let conditions = self.selectedReport?.conditions {
                    weatherReportVC.conditions = conditions
                }
                if let airport = self.selectedReport?.airport {
                    weatherReportVC.airport = airport
                }
                
            }
        }
    }

    /// Alert user when airport entry is invalid
    ///
    /// - Parameters:
    ///     - airport: the invalid airport name
    func presentInvalidAirportAlert(airport: String)
    {
        let message = airport + " is an invalid airport"
        
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle:.alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default)
                  { action -> Void in
                    // Put your code here
                  })
        self.present(alertController, animated: true, completion: nil)
    }

    /// Alert user when airport entry is invalid
    ///
    /// - Parameters:
    ///     - airport: the  airport name to query against API
    @IBAction func didTapSubmitButton(_ sender: Any) {
        let airport = searchTextField.text!.uppercased()
        self.searchTextField.text?.removeAll()
        
        getReport(airport: airport)
    }

    /// Invoke the fetch Report service's getReport method on the airport
    /// Convert returned json into a Report NSMangedObject and persist it in Core Data
    /// Refresh tableView with call to getReportsFromCoreData
    ///
    /// - Parameters:
    ///     - airport: the  airport name to query against API
    func getReport(airport: String, shouldShowReport: Bool = true) {
        Task {
            let reportJson = await self.fetchReportService.getReport(airport: airport)
            
            if reportJson == nil {
                DispatchQueue.main.async {
                    self.presentInvalidAirportAlert(airport: airport)
                }
            } else {
                // Create new report in Core Data and save it
                let report = coreDataService.reportFromJson(airport, reportJson!)
                await coreDataService.saveContext()
                
                // Get all reports from core data and refresh TableView
                getReportsFromCoreData()
                self.selectedReport = report
                if shouldShowReport {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "WeatherReportSegue", sender: nil)
                    }
                }
            }
        }
    }

}


extension AirportListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedReport = self.reports[indexPath.row]
        self.performSegue(withIdentifier: "WeatherReportSegue", sender: nil)
    }
}


extension AirportListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reports.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = reports[indexPath.row].airport

        return cell
    }
}
