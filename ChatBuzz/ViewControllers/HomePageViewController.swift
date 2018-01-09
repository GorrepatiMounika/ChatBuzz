//
//  HomePageViewController.swift
//  ChatBuzz
//
//  Created by Flashmac2 on 09/12/17.
//  Copyright © 2017 Flashmac2. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation
import GooglePlacesSearchController
import  MapKit
import Alamofire

class HomePageViewController: UIViewController, GMSMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var imagesView: UIView!
    @IBOutlet var ViewMap: GMSMapView!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var chatButton: UIButton!
    @IBOutlet var distanceButton: UIButton!
    @IBOutlet var sourceTextField: UITextField!
    @IBOutlet var destinationTextField: UITextField!
    @IBOutlet var showDirection: UIButton!
    @IBOutlet var sourceLabel: UILabel!
    @IBOutlet var destinationLabel: UILabel!
    @IBOutlet var distance: UILabel!
    @IBOutlet var distanceText: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var timeText: UILabel!
    @IBOutlet var label: UILabel!
    @IBOutlet var labelsView: UIView!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var currentLocation: UIButton!
    @IBOutlet var selectYourLocation: UIButton!
    @IBOutlet var share: UIButton!
    
    
     let locationManager = CLLocationManager()
    var sourceLocation = CLLocation()
    var destinationLocation = CLLocation()
    var newLocation = CLLocation()
    var sourceId = String()
    var destinationId = String()
    var tag = Int()
    var marker = GMSMarker()
    var routes = [Any]()
    var sourcename = String()
     let ceo: CLGeocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       createtextfield()
       createViewMap()
        createLabel()
    }
    
    func createtextfield() {
        sourceTextField.isHidden = true
        destinationTextField.isHidden = true
        showDirection.isHidden = true
        segmentControl.isHidden = true
        currentLocation.isHidden = true
        selectYourLocation.isHidden = true
        share.isHidden = true
    }
    
    
    func createViewMap()  {
        ViewMap.delegate  = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 500
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        self.view = ViewMap
    }
    func createLabel() {
        
        sourceLabel.isHidden = true
        destinationLabel.isHidden = true
        distance.isHidden = true
        distanceText.isHidden = true
        time.isHidden = true
        timeText.isHidden = true
        label.isHidden = true
        
    }
    func EnableLabel() {
        sourceLabel.isHidden = false
        destinationLabel.isHidden = false
        distance.isHidden = false
        distanceText.isHidden = false
        time.isHidden = false
        timeText.isHidden = false
        label.isHidden = false
        
    }
    @objc func myTargetFunction(_sender: UITextField) {
        tag = _sender.tag
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    @objc func routePath() {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        guard  let source = sourceTextField.text,  let dest = destinationTextField.text else {
            return
        }
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source)&destination=\(dest)&region=es&key=AIzaSyBls_LyXESaMnp-Gh7uZci63J2kPj-C4tk")!
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any]{
                        self.ViewMap.clear()
                            self.routes = (json["routes"] as? [Any])!
                            let arrayLegs = self.routes.last as? [String: Any]
                            let legs = arrayLegs!["legs"] as? [Any]
                            let arraySteps = legs!.last as? [String: Any]
                            let dictDistance = arraySteps!["distance"] as? [String: Any]
                            let text = dictDistance!["text"] as? String
                            let dictDuration = arraySteps!["duration"] as? [String: Any]
                            let duration = dictDuration!["text"] as? String
                            
                            let arraypoints = self.routes.last as? [String:Any]
                            let overview_polyline = arraypoints!["overview_polyline"] as? [String: Any]
                            let polyString = overview_polyline!["points"] as! String
                            
                            DispatchQueue.main.async {
                                let path = GMSPath(fromEncodedPath: polyString)
                                let polyline = GMSPolyline(path: path)
                                polyline.strokeWidth = 4
                                polyline.strokeColor = UIColor.blue
                                polyline.map = self.ViewMap
                                self.ViewMap.isMyLocationEnabled = false
                                self.ViewMap.animate(toLocation: CLLocationCoordinate2D(latitude: self.sourceLocation.coordinate.latitude, longitude: self.sourceLocation.coordinate.longitude))
                                self.ViewMap.animate(toLocation: CLLocationCoordinate2D(latitude: self.destinationLocation.coordinate.latitude, longitude: self.destinationLocation.coordinate.longitude))


                                self.marker(coordinate: self.sourceLocation, coordinate1: self.destinationLocation)
                                self.EnableLabel()
                                self.sourceLabel.text = self.sourceTextField.text
                                self.destinationLabel.text = self.destinationTextField.text
                                self.distanceText.text = text
                                self.timeText.text = duration
                            }
                       
                    }
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    func marker (coordinate: CLLocation, coordinate1: CLLocation) {
        let position = CLLocationCoordinate2D(latitude: self.sourceLocation.coordinate.latitude, longitude: self.sourceLocation.coordinate.longitude)
        self.marker = GMSMarker(position: position)
        self.marker.icon = GMSMarker.markerImage(with: UIColor.green)
        self.marker.map = self.ViewMap
        let position1 = CLLocationCoordinate2D(latitude: self.destinationLocation.coordinate.latitude, longitude: self.destinationLocation.coordinate.longitude)
        self.marker = GMSMarker(position: position1)
        self.marker.icon = GMSMarker.markerImage(with: UIColor.red)
        self.marker.map = self.ViewMap
    }
    
    @IBAction func directionButtonClickAction(_ sender: Any) {
        sourceTextField.isHidden = false
        destinationTextField.isHidden = false
        showDirection.isHidden = false
        sourceTextField.delegate = self
        destinationTextField.delegate = self
         sourceTextField.text = sourcename
        sourceTextField.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
        destinationTextField.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
    }
    
    @IBAction func shareButtonClickAction(_ sender: Any) {
        sourceTextField.isHidden = true
        destinationTextField.isHidden = true
        showDirection.isHidden = true
        segmentControl.isHidden = false
    }
    
    @IBAction func currentLocationButtonClickAction(_ sender: Any) {
        
        var shareArray = [Any]()
     
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            shareArray = [URL(string: "comgooglemapsurl://maps.google.com/?q=\(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude)")!]
        }
        else {
            shareArray = [URL(string: "https://maps.google.com/?q=\(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude)")!]
        }
        let activityViewController = UIActivityViewController(activityItems: shareArray, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func segmentControlButtonClickAction(_ sender: Any) {
        let tag = segmentControl.selectedSegmentIndex
        
        switch tag {
        case 0:
            print("segment1")
        case 1:
            print("segment2")
        case 2:
           currentLocation.isHidden = false
           selectYourLocation.isHidden = false
            
        default:
            break
        }
        
    }
    
    @IBAction func selectYourCurrentLocationButtonClickAction(_ sender: Any) {
        sourceTextField.isHidden = false
        destinationTextField.isHidden = false
        share.isHidden = false
        destinationTextField.delegate = self
        sourceTextField.text = sourcename
        sourceTextField.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
        destinationTextField.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
    }
   
    @IBAction func shareCurrentLocation(_ sender: Any) {
        var shareData = [Any]()
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            shareData = [URL(string: "comgooglemapsurl://maps.google.com/?saddr=\(sourceLocation.coordinate.latitude),\(sourceLocation.coordinate.longitude)&daddr=\(destinationLocation.coordinate.latitude),\(destinationLocation.coordinate.longitude)&directionsmode=driving&zoom=14&views=traffic")]
            }
            else {
            shareData = [URL(string: "https://maps.google.com/?saddr=\(sourceLocation.coordinate.latitude),\(sourceLocation.coordinate.longitude)&daddr=\(destinationLocation.coordinate.latitude),\(destinationLocation.coordinate.longitude)&directionsmode=driving&zoom=14&views=traffic")]
            }
        
        let activityViewController = UIActivityViewController(activityItems: shareData, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension HomePageViewController:  CLLocationManagerDelegate {
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        newLocation = locations.first!
        ViewMap.camera = GMSCameraPosition.camera(withLatitude: newLocation.coordinate.latitude, longitude: (newLocation.coordinate.longitude), zoom: 15.0)
        ViewMap = GMSMapView.map(withFrame: ViewMap.frame, camera: ViewMap.camera)
        ViewMap.settings.myLocationButton = true
        self.ViewMap.isMyLocationEnabled = true
        self.ViewMap.addSubview(imagesView)
//        self.ViewMap.addSubview(labelsView)
        self.view = self.ViewMap
        
        let loc: CLLocation = CLLocation(latitude:newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    if let locationName = pm.addressDictionary!["Name"] as? NSString {
                       self.sourcename = locationName as String
                        print(locationName.capitalized)
                    
                    }
                }
        })

    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
extension HomePageViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
      
        switch tag {
        case 0:
             sourceTextField.text = place.name
             sourceLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
             sourceId = place.placeID
             showDirection.addTarget(self, action: #selector(routePath), for: .touchUpInside)
              share.addTarget(self, action: #selector(routePath), for: .touchUpInside)
             dismiss(animated: true, completion: nil)
        case 1:
            destinationTextField.text = place.name
            destinationLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            destinationId = place.placeID
            showDirection.addTarget(self, action: #selector(routePath), for: .touchUpInside)
             share.addTarget(self, action: #selector(routePath), for: .touchUpInside)
            dismiss(animated: true, completion: nil)

        default:
            break
        }
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

