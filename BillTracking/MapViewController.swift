//
//  MapViewController.swift
//  BillTracking
//
//  Created by Carter Liu on 11/1/20.
//  Copyright © 2020 Carter Liu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var tickerTextField: UITextField!
    @IBOutlet weak var currentTicker: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var openPrice: UILabel!
    @IBOutlet weak var highPrice: UILabel!
    @IBOutlet weak var lowPrice: UILabel!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        determineCurrentLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Error - locationManager: \(error.localizedDescription)")
        }
    //MARK:- Intance Methods

    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mUserLocation:CLLocation = locations[0] as CLLocation
        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
        let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(mRegion, animated: true)
        print(map.region)
        // Get user's Current Location and Drop a pin
        let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
        mkAnnotation.coordinate = CLLocationCoordinate2DMake(mUserLocation.coordinate.latitude, mUserLocation.coordinate.longitude)
        mkAnnotation.title = "CURRENT LOCATION"
        map.addAnnotation(mkAnnotation)
        findATMS(lat: mUserLocation.coordinate.latitude, long: mUserLocation.coordinate.longitude)
    }
   
    func findATMS(lat: CLLocationDegrees, long: CLLocationDegrees){
        let word = "ATM"
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = word
        
        let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let span: MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region: MKCoordinateRegion = MKCoordinateRegion.init(center: coordinates, span: span)
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            var matchingItems:[MKMapItem] = []
            matchingItems = response.mapItems
            for i in matchingItems
            {
                let place = i.placemark
                let annotation = MKPointAnnotation()
                annotation.coordinate = place.coordinate
                annotation.title = place.name
                self.map.addAnnotation(annotation)
            }
           
        }
    }
    
    @IBAction func searchStock(_ sender: Any) {
        
        if let ticker = tickerTextField?.text{
            let trimmed = ticker.replacingOccurrences(of: " ", with: "")
            let url = URL(string: "https://finnhub.io/api/v1/quote?symbol=\(trimmed)&token=buutpif48v6rf2qodeq0")!
            let urlSession = URLSession.shared
            
            let jsonQuery = urlSession.dataTask(with: url, completionHandler: { data, response, error -> Void in
                if error == nil{
                    let decoder = JSONDecoder()
                    
                    let jsonResult = try? decoder.decode(Root.self, from: data!)
                    if jsonResult!.c != 0{
                        
                        DispatchQueue.main.async {
                            self.currentTicker.text = String(ticker)
                            self.currentTicker.textColor = UIColor.black
                            self.currentPrice.text = "Current: \(jsonResult!.c )"
                            self.highPrice.text = "High: \(jsonResult!.h )"
                            self.lowPrice.text = "Low: \(jsonResult!.l )"
                            self.openPrice.text = "Open: \(jsonResult!.o)"
                            self.currentPrice.textColor = UIColor.black
                            self.currentPrice.sizeToFit()
                            self.highPrice.sizeToFit()
                            self.lowPrice.sizeToFit()
                            self.openPrice.sizeToFit()
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.currentPrice.text = "ENTER VALID TICKER"
                            self.openPrice.text = "Example: TSLA"
                            self.openPrice.sizeToFit()
                            self.highPrice.text = ""
                            self.lowPrice.text = ""
                            self.currentTicker.text = "ERR"
                            self.currentTicker.textColor = UIColor.red
                            self.currentPrice.textColor = UIColor.red
                            self.currentPrice.sizeToFit()
                        }
                        
                    }
                    
                }
            })
            jsonQuery.resume()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
