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
    }
    
    func getReportsFromCoreData() {
        // Get reports from Core Data and refresh tableView
        Task {
            self.reports = await coreDataService.fetchReports()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    


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

    @IBAction func didTapSubmitButton(_ sender: Any) {
        let airport = searchTextField.text!.uppercased()

        self.searchTextField.text?.removeAll()
        Task {
            let report = await self.fetchReportService.getReport(airport: airport)
            
            if report == nil {
                DispatchQueue.main.async {
                    self.presentInvalidAirportAlert(airport: airport)
                }
            } else {
                getReportsFromCoreData()
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
