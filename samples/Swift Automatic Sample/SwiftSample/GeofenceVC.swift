/*
 * Copyright © 2016, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

import UIKit
import MapKit

class GeofenceVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var gpsButton: UIBarButtonItem!
    @IBOutlet weak var status: UIButton!
    
    var locationManager: CLLocationManager?
    var lastLocation: CLLocation?
    var followGPS: Bool = true
    var overlayIds = Set<String>()
    var queue = DispatchQueue(label: "background")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(forName: MCENotificationName.DownloadedLocations.rawValue, object: nil, queue: OperationQueue.main) { (note) in
            self.addGeofenceOverlaysNearCoordinate(coordinate: self.lastLocation!.coordinate, radius: 1000)
        }
    }
    
    func updateStatus()
    {
        let config = MCESdk.shared.config;
        if(config!.geofenceEnabled)
        {
            switch(CLLocationManager.authorizationStatus())
            {
            case .denied:
                status.setTitle("DENIED", for: .normal)
                status.setTitleColor(.failure, for: .normal)
                break
            case .notDetermined:
                status.setTitle("DELAYED (Touch to enable)", for: .normal)
                status.setTitleColor(.disabled, for: .normal)
                break
            case .authorizedAlways:
                status.setTitle("ENABLED", for: .normal)
                status.setTitleColor(.success, for: .normal)
                break
            case .restricted:
                status.setTitle("RESTRICTED?", for: .normal)
                status.setTitleColor(.disabled, for: .normal)
                break
            case .authorizedWhenInUse:
                status.setTitle("ENABLED WHEN IN USE", for: .normal)
                status.setTitleColor(.disabled, for: .normal)
                break
            @unknown default:
                status.setTitle("UNKNOWN", for: .normal)
                status.setTitleColor(.disabled, for: .normal)
                break
            }
        }
        else
        {
            status.setTitle("DISABLED", for: .normal)
            status.setTitleColor(.failure, for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatus()
        createMonitor()
    }
    
    func createMonitor()
    {
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.startUpdatingLocation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        destroyMonitor()
    }
    
    func destroyMonitor()
    {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        if let locationManager = locationManager
        {
            locationManager.stopUpdatingLocation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followGPS=true
        updateGpsButton()
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(didDragMap(gestureRecognizer:)))
        panRec.delegate=self
        mapView.addGestureRecognizer(panRec)
        mapView.showsUserLocation=true
        mapView.delegate=self
    }
    
    @objc func didDragMap(gestureRecognizer: UIGestureRecognizer)
    {
        if(gestureRecognizer.state == UIGestureRecognizer.State.ended)
        {
            followGPS=false
            updateGpsButton()
            let region = mapView.region
            let location = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
            if lastLocation != nil || lastLocation!.distance(from: location) > 10
            {
                let north = CLLocation(latitude: region.center.latitude - region.span.latitudeDelta * 0.5, longitude: region.center.longitude)
                let south = CLLocation(latitude: region.center.latitude + region.span.latitudeDelta * 0.5, longitude: region.center.longitude)
                let metersLatitude = north.distance(from: south)
                
                let east = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude - region.span.longitudeDelta * 0.5)
                let west = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude + region.span.longitudeDelta * 0.5)
                let metersLongitude = east.distance(from: west)
                
                let maxMeters = max(metersLatitude, metersLongitude)
                addGeofenceOverlaysNearCoordinate(coordinate: location.coordinate, radius: maxMeters)
                lastLocation = location
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    @IBAction func enable(sender: AnyObject)
    {
        MCESdk.shared.manualLocationInitialization()
    }
    
    @IBAction func refresh(sender: AnyObject)
    {
        MCELocationClient().scheduleSync()
    }
    
    @IBAction func clickGpsButton(sender: AnyObject)
    {
        followGPS = !followGPS
        updateGpsButton()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateGpsButton()
    }
    
    func updateGpsButton() {
        var color = UIColor.tint
        
        if !followGPS {
            color = color.withAlphaComponent(0.2)
        }
        gpsButton.tintColor = color
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        if(followGPS)
        {
            let region = MKCoordinateRegion.init(center: location!.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
        
        if(lastLocation == nil || lastLocation!.distance(from: location!)>10)
        {
            addGeofenceOverlaysNearCoordinate(coordinate: location!.coordinate, radius: 1000)
            lastLocation = location
        }
    }
    
    func addGeofenceOverlaysNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double)
    {
        let r = min(radius, 10000)
        DispatchQueue.global().async {
            var overlays = [MKOverlay]()
            var annotations = [MKAnnotation]()
            if let geofences = MCELocationDatabase.shared.geofencesNearCoordinate(coordinate, radius: r)
            {
                for geofence in geofences
                {
                    if let geofence = geofence as? MCEGeofence
                    {
                        if !self.overlayIds.contains(geofence.locationId)
                        {
                            let circle = MKCircle(center: geofence.coordinate, radius: geofence.radius)
                            circle.title = geofence.locationId
                            overlays.append(circle)
                            self.overlayIds.insert(geofence.locationId)
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = geofence.coordinate
                            annotation.title = geofence.locationId
                            annotation.subtitle = String(format: "Latitude %f, Longitude %f, Radius: %.1f", geofence.coordinate.latitude, geofence.coordinate.longitude, geofence.radius)
                            annotations.append(annotation)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.mapView.addOverlays(overlays)
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
    func overlayActive(overlay: MKOverlay) -> Bool {
        guard let locationManager = locationManager, let circle = overlay as? MKCircle, let identifier = circle.title else {
            return false
        }
        for region in locationManager.monitoredRegions {
            if region.identifier == identifier {
                return true
            }
        }
        return false
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let active = overlayActive(overlay: overlay)
        let renderer = MKCircleRenderer(overlay: overlay)
        
        if active {
            renderer.fillColor = UIColor.systemRed.withAlphaComponent(0.1)
            renderer.strokeColor = UIColor.systemRed
        } else {
            renderer.fillColor = UIColor.systemGreen.withAlphaComponent(0.1)
            renderer.strokeColor = UIColor.systemGreen
        }
        renderer.lineWidth = 1
        renderer.lineDashPattern = [2,2]
        return renderer
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateStatus()
    }
}


