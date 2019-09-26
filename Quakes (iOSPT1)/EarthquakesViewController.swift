//
//  EarthquakesViewController.swift
//  Quakes (iOSPT1)
//
//  Created by Dongwoo Pae on 9/26/19.
//  Copyright © 2019 Dongwoo Pae. All rights reserved.
//

import UIKit
import MapKit

class EarthquakesViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: properties
    private let quakeFetcher = QuakeFether()
    private var quakes = [Quake]() {
        didSet {
            let oldQuakes = Set(oldValue)
            let newQuakes = Set(self.quakes)
            let addedQuakes = Array(newQuakes.subtracting(oldQuakes))
            let removedQuakes = Array(oldQuakes.subtracting(newQuakes))
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(removedQuakes)
                self.mapView.addAnnotations(addedQuakes)
            }
        }
    }
    private let locationManager = CLLocationManager()
    private var userTrackingButton: MKUserTrackingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.mapView.delegate = self and conform MKMapViewDelegate -> this is same as dragging mapview to viewcontroller delegate
        locationManager.requestWhenInUseAuthorization()
        
        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(userTrackingButton)
        
        userTrackingButton.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20).isActive = true
        userTrackingButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20).isActive = true
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "QuakeAnnotationView")
        
        self.fetchQuakes()
    }
    
    private func fetchQuakes() {
        let visibleRegion = CoordinateRegion(mapRect: mapView.visibleMapRect)
        quakeFetcher.fetchQuakes(in: visibleRegion) { (quakes, error) in
            if let error = error {
                NSLog("error fetching quakes: \(error)")
            }
            self.quakes = quakes ?? []
        }
    }
    
    //MARK:
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        fetchQuakes()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let quake = annotation as? Quake else {return nil}
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "QuakeAnnotationView", for: quake) as! MKMarkerAnnotationView
        annotationView.glyphTintColor = .white
        annotationView.glyphImage = UIImage(named: "QuakeIcon")!
        
        annotationView.canShowCallout = true
        let detailView = QuakeDetailView(frame: .zero)
        detailView.quake = quake
        annotationView.detailCalloutAccessoryView = detailView
        
        return annotationView
    }
}

