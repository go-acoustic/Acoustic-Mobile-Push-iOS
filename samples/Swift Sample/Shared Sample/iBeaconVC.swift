/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

import Foundation
import CoreLocation
import UIKit
import AcousticMobilePush

class iBeaconVC: UITableViewController, CLLocationManagerDelegate {
    var beaconRegions = [CLBeaconRegion]()
    var beaconStatus = [NSNumber:String]()
    var locationManager: CLLocationManager?
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        tableView.reloadRows(at: [IndexPath(item: 1, section:0)], with: .automatic)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager()
            self.locationManager!.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let regions = MCELocationDatabase.shared.beaconRegions()
        {
            self.beaconRegions = regions.sortedArray(using: [ NSSortDescriptor(key: "major", ascending: true) ]) as! [CLBeaconRegion]
        }
        else
        {
            self.beaconRegions = []
        }
        
        NotificationCenter.default.addObserver(forName: MCENotificationName.EnteredBeacon.rawValue, object: nil, queue: OperationQueue.main) {
            notification in
            self.beaconStatus[notification.userInfo!["major"] as! NSNumber] = String.init(format: "Entered Minor %@", notification.userInfo!["minor"] as! NSNumber)
            self.tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(forName: MCENotificationName.ExitedBeacon.rawValue, object: nil, queue: OperationQueue.main) {
            notification in
            self.beaconStatus[notification.userInfo!["major"] as! NSNumber] = String.init(format: "Exited Minor %@", notification.userInfo!["minor"] as! NSNumber)
            self.tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(forName: MCENotificationName.LocationDatabaseUpdated.rawValue, object: nil, queue: OperationQueue.main)
        {
            notification in
            
            if let beaconRegions = MCELocationDatabase.shared.beaconRegions() {
                self.beaconRegions = beaconRegions.sortedArray(using: [ NSSortDescriptor(key: "major", ascending: true) ]) as! [CLBeaconRegion]
            }
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func refresh(sender: AnyObject) {
        MCELocationClient().scheduleSync()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0)
        {
            let vertical = tableView.dequeueReusableCell(withIdentifier: "vertical", for: indexPath)
            let config = MCESdk.shared.config;
            if(indexPath.item==0)
            {
                vertical.textLabel!.text = "UUID"
                if let uuid = config.beaconUUID
                {
                    vertical.detailTextLabel!.text = uuid.uuidString
                    vertical.detailTextLabel!.textColor = .success
                }
                else
                {
                    vertical.detailTextLabel!.text = "UNDEFINED"
                    vertical.detailTextLabel!.textColor = .disabled
                }
            }
            else
            {
                vertical.textLabel!.text = "Status"
                if(config.beaconEnabled)
                {
                    switch(CLLocationManager.authorizationStatus())
                    {
                    case .denied:
                        vertical.detailTextLabel!.text = "DENIED"
                        vertical.detailTextLabel!.textColor = .failure
                        break
                    case .notDetermined:
                        vertical.detailTextLabel!.text = "DELAYED (Touch to enable)"
                        vertical.detailTextLabel!.textColor = .disabled
                        break
                    case .authorizedAlways:
                        vertical.detailTextLabel!.text = "ENABLED"
                        vertical.detailTextLabel!.textColor = .success
                        break
                    case .restricted:
                        vertical.detailTextLabel!.text = "RESTRICTED?"
                        vertical.detailTextLabel!.textColor = .disabled
                        break
                    case .authorizedWhenInUse:
                        vertical.detailTextLabel!.text = "ENABLED WHEN IN USE"
                        vertical.detailTextLabel!.textColor = .disabled
                        break
                    @unknown default:
                        vertical.detailTextLabel!.text = "UNKNOWN"
                        vertical.detailTextLabel!.textColor = .disabled
                    }
                }
                else
                {
                    vertical.detailTextLabel!.text = "DISABLED"
                    vertical.detailTextLabel!.textColor = .failure
                }
            }
            return vertical;
        }
        
        let basic = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
        let major = self.beaconRegions[indexPath.item].major
        basic.textLabel!.text = String(format: "%@", major!)
        if self.beaconStatus[major!] != nil
        {
            basic.detailTextLabel!.text = self.beaconStatus[major!]
        }
        else
        {
            basic.detailTextLabel!.text = ""
        }
        
        return basic
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.item == 1
        {
            MCESdk.shared.manualLocationInitialization()
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section==0)
        {
            return 2
        }
        return self.beaconRegions.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section==0)
        {
            return "iBeacon Feature"
        }
        return "iBeacon Major Regions"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}
