//
//  MapViewController.swift
//  Dardasha
//
//  Created by Ahmed on 13/10/2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    var location: CLLocation?
    var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Map View"
        configureLeftBarButton()
        configureMapView()
    }
    
    private func configureMapView(){
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        mapView.showsUserLocation = true
        
        if location != nil {
            mapView.setCenter(location!.coordinate, animated: false)
            
            // add anotation
            mapView.addAnnotation(MapAnnotation(title: "User Location", coordinate: location!.coordinate))
        }
        view.addSubview(mapView)
    }
    
    private func configureLeftBarButton(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonPressed))
    }
    
    @objc func backButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
}
