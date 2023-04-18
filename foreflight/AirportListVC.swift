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

    var report: Report?
    var coreDataService: CoreDataService!
    var fetchReportService: FetchReportService!
    var reports: [Report] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get reports from Core Data
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
                if let forecast = self.report?.forecast {
                    weatherReportVC.forecast = forecast
                }
                if let conditions = self.report?.conditions {
                    weatherReportVC.conditions = conditions
                }
                if let airport = self.report?.airport {
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
////        print(searchText)

        self.searchTextField.text?.removeAll()
        Task {
            let report = await self.fetchReportService.getReport(airport: airport)
            if report == nil {
                DispatchQueue.main.async {
                    self.presentInvalidAirportAlert(airport: airport)
                }
            }
        }
    }

}



extension AirportListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.report = self.reports[indexPath.row]
        self.performSegue(withIdentifier: "WeatherReportSegue", sender: nil)
//        let airport = airports
//        getWeatherReport(airport: airport)
//        print("you tapped me")
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
