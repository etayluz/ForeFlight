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
    
    var airports = ["KPWM"]
    var reportDic = [String: Any]()
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
                        self.reportDic = dictionary!
                        DispatchQueue.main.async {
                            if !self.airports.contains(airport) {
                                self.airports.append(airport)
                                self.tableView.reloadData()
                            }
                            
                            self.performSegue(withIdentifier: "WeatherReportSegue", sender: nil)
                        }
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
                weatherReportVC.reportDic = self.reportDic
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
        let searchText = searchTextField.text!.uppercased()
//        print(searchText)
        self.getWeatherReport(airport: searchText)
        self.searchTextField.text?.removeAll()
    }

}



extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let airport = airports[indexPath.row]
        getWeatherReport(airport: airport)
//        print("you tapped me")
    }
}



extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return airports.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = airports[indexPath.row]
        return cell
    }
}

//extension ViewController {
//    func save(value:String) {
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            let context = appDelegate.persistentContainer.viewContext
//            
//            guard let entityDescription = NSEntityDescription.entity(forEntityName: "foreflight", in: context) else {
//                return
//            }
//            
//        }
//    }
//}
