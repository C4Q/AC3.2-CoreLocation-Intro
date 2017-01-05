//
//  DemoLocationViewController.swift
//  AC3.2-CoreLocation-MKMaps
//
//  Created by Louis Tur on 1/5/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class DemoLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
  
  let locationManager: CLLocationManager = {
    let locMan: CLLocationManager = CLLocationManager()
    // more here later
    locMan.desiredAccuracy = 100.0
    locMan.distanceFilter = 50.0
    return locMan
  }()
  
  let geocoder: CLGeocoder = CLGeocoder()
  
  
  // MARK: - View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    
    locationManager.delegate = self
    mapView.delegate = self
    
    setupViewHierarchy()
    configureConstraints()
  }
  
  
  // MARK: - Setup
  func configureConstraints() {
    let _ = [
      latLabel,
      longLabel,
      permissionButton,
      geocodeLocationLabel,
      mapView,
      ].map{ $0.translatesAutoresizingMaskIntoConstraints = false }
    
    let _ = [
      // labels
      latLabel.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 8.0),
      latLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      
      longLabel.topAnchor.constraint(equalTo: latLabel.bottomAnchor, constant: 8.0),
      longLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      
      geocodeLocationLabel.topAnchor.constraint(equalTo: longLabel.bottomAnchor, constant: 8.0),
      geocodeLocationLabel.centerXAnchor.constraint(equalTo: longLabel.centerXAnchor),
      
      // map
      mapView.topAnchor.constraint(equalTo: geocodeLocationLabel.bottomAnchor, constant: 16.0),
      mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      mapView.bottomAnchor.constraint(equalTo: permissionButton.topAnchor, constant: -16.0),
      
      // buttons
      permissionButton.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -16.0),
      permissionButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      ].map { $0.isActive = true }
  }
  
  func setupViewHierarchy() {
    
    // labels
    self.view.addSubview(latLabel)
    self.view.addSubview(longLabel)
    self.view.addSubview(geocodeLocationLabel)
    
    // buttons
    self.view.addSubview(permissionButton)
    
    // map
    self.view.addSubview(mapView)
    
    // actions
    permissionButton.addTarget(self, action: #selector(didPressPermissionsButton(sender:)), for: .touchUpInside)
  }
  
  // MARK: - MKMapView Delegate
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let circleRenderer: MKCircleRenderer = MKCircleRenderer(overlay: overlay as! MKCircle)
    circleRenderer.lineWidth = 1.0
    circleRenderer.strokeColor = UIColor.blue
    circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.2)

    return circleRenderer
  }
  
  
  // MARK: - CLLocationManager Delegate
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      print("All good")
            manager.startUpdatingLocation()
//      manager.startMonitoringSignificantLocationChanges()
      
    case .denied, .restricted:
      print("NOPE")
      
    case .notDetermined:
      print("IDK")
      locationManager.requestAlwaysAuthorization()
      
    }
    
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("Oh woah, locations updated")
    //    dump(locations)
    
    guard let validLocation: CLLocation = locations.last else { return }
    
    print("Valid location")
    // Display this with only 4 signification digits after the decimal
    // Hint: Use a specific string formatting initializer
    // Or: Do it the harder way with removing a range of string.
    
    // May the odds be ever in your favor. <mockingbird>
    //    self.latLabel.text = "Lat: \(validLocation.coordinate.latitude)"
    //    self.longLabel.text = "Long: \(validLocation.coordinate.longitude)"
    
    self.latLabel.text = String(format: "Lat: %0.4f", validLocation.coordinate.latitude)
    self.longLabel.text = String(format: "Long: %0.4f", validLocation.coordinate.longitude)
    
//    mapView.setCenter(validLocation.coordinate, animated: true)
    mapView.setRegion(MKCoordinateRegionMakeWithDistance(validLocation.coordinate, 500.0, 500.0), animated: true)
    
    let pinAnnotation: MKPointAnnotation = MKPointAnnotation()
    pinAnnotation.title = "Hey, Title"
    pinAnnotation.subtitle = "Hellow, Subtitle"
    pinAnnotation.coordinate = validLocation.coordinate
    mapView.addAnnotation(pinAnnotation)
    
    let circleOverlay: MKCircle = MKCircle(center: validLocation.coordinate, radius: 50.0)
    
    mapView.add(circleOverlay)
    
    geocoder.reverseGeocodeLocation(validLocation) { (placemarks: [CLPlacemark]?, error: Error?) in
      if error != nil {
        dump(error!)
      }
      
      guard
        let validPlaceMarks: [CLPlacemark] = placemarks,
        let validPlace: CLPlacemark = validPlaceMarks.last
        else {
          return
      }
      
      self.geocodeLocationLabel.text = "\(validPlace.name!) \t \(validPlace.locality!)"
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Error encounter")
    dump(error)
  }
  
  
  // MARK: - Actions
  internal func didPressPermissionsButton(sender: UIButton) {
    print("Tapped Permissions!")
    
    // Check for permissions
    switch CLLocationManager.authorizationStatus() {
      
    case .authorizedAlways, .authorizedWhenInUse:
      print("All good")
      
    case .denied, .restricted:
      print("NOPE")
      
      // UIApplication
      guard let validSettingsURL: URL = URL(string: UIApplicationOpenSettingsURLString) else { return }
      UIApplication.shared.open(validSettingsURL, options: [:], completionHandler: nil)
      
    case .notDetermined:
      print("IDK")
      locationManager.requestAlwaysAuthorization()
    }
    
  }
  
  
  // MARK: - Lazy Instances
  internal var latLabel: UILabel = {
    let label: UILabel = UILabel()
    label.text = "Lat: "
    label.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightHeavy)
    return label
  }()
  
  internal var longLabel: UILabel = {
    let label: UILabel = UILabel()
    label.text = "Long: "
    label.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightHeavy)
    return label
  }()
  
  internal var geocodeLocationLabel: UILabel = {
    let label: UILabel = UILabel()
    label.font = UIFont.systemFont(ofSize: 24.0, weight: UIFontWeightThin)
    return label
  }()
  
  internal var mapView: MKMapView = {
    let map: MKMapView = MKMapView()
    // more on this later
    map.mapType = MKMapType.satellite
    return map
  }()
  
  internal var permissionButton: UIButton = {
    let button: UIButton = UIButton(type: .custom)
    button.setTitle("Prompt for Permission", for: .normal)
    button.backgroundColor = .yellow
    button.setTitleColor(.blue, for: .normal)
    button.contentEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    return button
  }()
  
}
