//
//  DemoLocationViewController.swift
//  AC3.2-CoreLocation-MKMaps
//
//  Created by Louis Tur on 1/5/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import CoreLocation

class DemoLocationViewController: UIViewController, CLLocationManagerDelegate {
  
  let locationManager: CLLocationManager = {
    let locMan: CLLocationManager = CLLocationManager()
    // more here later
    locMan.desiredAccuracy = 100.0
    locMan.distanceFilter = 50.0
    return locMan
  }()
  
  
  // MARK: - View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    
    locationManager.delegate = self
    
    setupViewHierarchy()
    configureConstraints()
  }
  
  
  // MARK: - Setup
  func configureConstraints() {
    let _ = [
      latLabel,
      longLabel,
      permissionButton,
      
      ].map{ $0.translatesAutoresizingMaskIntoConstraints = false }
    
    let _ = [
      // labels
      latLabel.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 8.0),
      latLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      
      longLabel.topAnchor.constraint(equalTo: latLabel.bottomAnchor, constant: 8.0),
      longLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      
      // buttons
      permissionButton.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -16.0),
      permissionButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      ].map { $0.isActive = true }
  }
  
  func setupViewHierarchy() {
    self.view.addSubview(latLabel)
    self.view.addSubview(longLabel)
    self.view.addSubview(permissionButton)
    
    permissionButton.addTarget(self, action: #selector(didPressPermissionsButton(sender:)), for: .touchUpInside)
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
    
    // Display this with only 4 signification digits after the decimal
    // Hint: Use a specific string formatting initializer
    // Or: Do it the harder way with removing a range of string. 
    
    // May the odds be ever in your favor. <mockingbird>
//    self.latLabel.text = "Lat: \(validLocation.coordinate.latitude)"
//    self.longLabel.text = "Long: \(validLocation.coordinate.longitude)"
    
    self.latLabel.text = String(format: "Lat: %0.4f", validLocation.coordinate.latitude)
    self.longLabel.text = String(format: "Lat: %0.4f", validLocation.coordinate.longitude)
    
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
  
  internal var permissionButton: UIButton = {
    let button: UIButton = UIButton(type: .custom)
    button.setTitle("Prompt for Permission", for: .normal)
    button.backgroundColor = .yellow
    button.setTitleColor(.blue, for: .normal)
    button.contentEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    return button
  }()
  
}
