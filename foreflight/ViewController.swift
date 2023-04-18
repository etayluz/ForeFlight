//
//  ViewController.swift
//  foreflight
//
//  Created by Etay Luz on 4/17/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!

    var report: Report?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // data for the table
    var reports: [Report]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get items from Core Data
        fetchReports()
        
    }

    func fetchReports() {
        
        // Fetch the data from Core Data to display in the tableView
        do {
            self.reports = try context.fetch(Report.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            
        }
    }

    func getWeatherReport(airport: String) {
        print(airport)
        // URL
        let url = URL(string: "https://qa.foreflight.com/weather/report/" + airport)
        
        guard url != nil else {
            print("Error creating URL object")
            return
        }
        
        // HRL Request
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        // Specify the headers
        let headers = ["ff-coding-exercise": "1"]
        request.allHTTPHeaderFields = headers
        
        // Set the request type
        request.httpMethod = "GET"
        
        // Get the URLSession
        let session = URLSession.shared

        // Create the data task
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil && data != nil {
                // Try to parse out the data
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any]
//                    print(dictionary!)
                    if dictionary!["error"] != nil {
                        print("Invalid airport: " + airport)
                        DispatchQueue.main.async {
                            self.searchTextField.text?.removeAll()
                            self.presentInvalidAirportAlert(airport: airport)
                        }
                    } else {
                        guard let dictionary = dictionary else {
                            print("Error with data")
                            return
                        }
                        let newReport = Report(context: self.context)
                        newReport.airport = airport
                        
                        if let report = dictionary["report"] as? JSONDictionary {
                //            print(report)
                            if let conditions = report["conditions"] as? JSONDictionary {
                //                print(conditions)
                                let jsonData = try? JSONSerialization.data(withJSONObject: conditions, options: [])
                                if let jsonString = String(data: jsonData!, encoding: .utf8) {
                                    newReport.conditions = jsonString
                                }
                            }
                            if let forecast = report["forecast"] as? JSONDictionary {
                //                print(forecast)
                                let jsonData = try? JSONSerialization.data(withJSONObject: forecast, options: [])
                                if let jsonString = String(data: jsonData!, encoding: .utf8) {
                                    newReport.forecast = jsonString
                                }
                            }
                        }
                        
                        // Save the data
                        do {
                            try self.context.save()
                        }
                        catch {
                            
                        }
                        
                        // Re-fetch the data
                        self.fetchReports()
                        
//                        DispatchQueue.main.async {
//                            if !self.airports.contains(airport) {
//                                self.airports.append(airport)
//                                self.tableView.reloadData()
//                            }
//
//                            self.performSegue(withIdentifier: "WeatherReportSegue", sender: nil)
//                        }
                    }
                }
                catch {
                    print("Error parsing response data")
                }
            }
        }
        
        // Fire off data task
        dataTask.resume()
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
//        print(searchText)
        // Check if airport is already saved
//        print(self.reports!)
        
        var airportExists = false
        for report in self.reports! {
            if report.airport == airport {
                print(report)
                airportExists = true
            }
            
        }
        
        if (!airportExists) {
            self.getWeatherReport(airport: airport)
        }
        self.searchTextField.text?.removeAll()
    }

}



extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.report = self.reports![indexPath.row]
        self.performSegue(withIdentifier: "WeatherReportSegue", sender: nil)
//        let airport = airports
//        getWeatherReport(airport: airport)
//        print("you tapped me")
    }
}



extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reports!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let reports = self.reports {
            cell.textLabel?.text = reports[indexPath.row].airport
        }

        return cell
    }
}
