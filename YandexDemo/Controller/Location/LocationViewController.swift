//
//  LocationViewController.swift
//  YandexDemo
//
//  Created by Bekzod Khaitboev on 8/1/21.
//

import UIKit
import YandexMapsMobile
import CoreLocation

class LocationViewController: UIViewController {
    
    var delegate: SearchDelegate?
    
    var searchManager = SearchManager()
    let currentLocation = CLLocationManager()
    var lan: Double = 0
    var lon: Double = 0
    
    let mapView = YMKMapView()
    func moveMap(latitude: Double, longitude: Double) {
       mapView.mapWindow.map.move(
                with: YMKCameraPosition.init(target: YMKPoint(latitude: lan, longitude: lon), zoom: 15, azimuth: 0, tilt: 0),
                animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 3),
                cameraCallback: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentLocation.delegate = self
        currentLocation.requestWhenInUseAuthorization()
        currentLocation.startUpdatingLocation()
        
        // MapView
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        
        
        
        // SearchBar
        let mySearchBar = UISearchBar()
        mySearchBar.delegate = self
        mySearchBar.placeholder = "Search"
        mySearchBar.layer.cornerRadius = 20
        mySearchBar.layer.masksToBounds = true
        //mySearchBar.endEditing(true)
        view.addSubview(mySearchBar)
        mySearchBar.translatesAutoresizingMaskIntoConstraints = false
        mySearchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        mySearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        mySearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        
        //Button
        let button = UIButton(type: UIButton.ButtonType.system) as UIButton
        button.backgroundColor = UIColor.lightGray
        button.setImage(#imageLiteral(resourceName: "Location_Icon-2"), for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = true
        button.backgroundColor = .white
        button.tintColor = UIColor.black
        button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        
        self.view.addSubview(button)
        self.view.addConstraintsWithFormat("H:[v0(50)]", views: button)
        self.view.addConstraintsWithFormat("V:[v0(50)]", views: button)
        
        button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -120).isActive = true
        button.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
    }

    
    @objc func buttonAction(_ sender:UIButton!) {
        moveMap(latitude: lan, longitude: lon)
    }
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar(animated: animated)
    }

}


// MARK: - UISearchBarDelegate
extension LocationViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let popUpVC = PopUpBottomController()
        popUpVC.delegate = self
        popUpVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        present(popUpVC, animated: true, completion: nil)
        
    }
    
}

/// CLLocationManagerDelegate

extension LocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lan = location.coordinate.latitude
            lon = location.coordinate.longitude
            moveMap(latitude: lan, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}


extension LocationViewController: SearchDelegate {
    func searchAndMove(langitude: Double, longitude: Double) {
        mapView.mapWindow.map.move(
                 with: YMKCameraPosition.init(target: YMKPoint(latitude: longitude, longitude: langitude), zoom: 15, azimuth: 0, tilt: 0),
                 animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 2),
                 cameraCallback: nil)
     }

}
