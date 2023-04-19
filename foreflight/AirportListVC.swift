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

        // Get all reports from core data and populate tableView
        Task { [weak self] in
            await self?.getReportsFromCoreData()
            if self?.reports.count == 0 {
                // Initially populate airport list with KPWM & KAUS
                await self?.getReport(airport: "KPWM", shouldShowReport: false)
                await self?.getReport(airport: "KAUS", shouldShowReport: false)
                await self?.coreDataService.saveContext()
                await self?.getReportsFromCoreData()
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }

        // automatically fetches updates for listed airports at a regular interval
        let interval = 10.0 // 10 second interval
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            if let reports = self?.reports {
                Task { [weak self] in
                    for report in reports {
                        await self?.getReport(airport: report.airport!, shouldShowReport: false)
                    }
                    await self?.coreDataService.saveContext()
                    await self?.getReportsFromCoreData()
                }
            }
        }
        
    }

    /// Fetch all reports from core data and reload tableView
    func getReportsFromCoreData() async {
        let reports = await self.coreDataService.fetchReports()
        self.reports = reports
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
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
        
        Task { [weak self] in
            await self?.getReport(airport: airport)
            await self?.coreDataService.saveContext()
            await self?.getReportsFromCoreData()
        }
    }

    /// Invoke the fetch Report service's getReport method on the airport
    /// Convert returned json into a Report NSMangedObject and persist it in Core Data
    /// Refresh tableView with call to getReportsFromCoreData
    ///
    /// - Parameters:
    ///     - airport: the  airport name to query against API
    func getReport(airport: String, shouldShowReport: Bool = true) async {
//        Task { [weak self] in
            if let reportJson = await self.fetchReportService.getReport(airport: airport) {
                
                // Create new report in Core Data and save it
                let report = self.coreDataService.reportFromJson(airport, reportJson)
                self.selectedReport = report
                if shouldShowReport {
                    DispatchQueue.main.async { [weak self] in
                        self?.performSegue(withIdentifier: "WeatherReportSegue", sender: nil)
                    }
                }
                
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.presentInvalidAirportAlert(airport: airport)
                }
            }
            
            
//        }
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
