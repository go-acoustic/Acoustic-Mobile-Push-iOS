/*
* Copyright © 2019, 2019 Acoustic, L.P. All rights reserved.
*
* NOTICE: This file contains material that is confidential and proprietary to
* Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
* industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
* Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
* prohibited.
*/

import UIKit

class StateController {
    static var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static func restore(state: NSDictionary, toWindow window: UIWindow) {
        guard let interface = state["interface"] as? String else {
            return
        }
        
        let classToIdentifier = [
            "MainVC": "Main",
            "AttributesVC": "Attributes",
            "CustomActionVC": "CustomAction",
            "EventVC": "Events",
            "GeofenceVC": "Geofences",
            "iBeaconVC": "iBeacons",
            "InAppVC": "In App",
            "RegistrationVC": "Registration",
            "MCEInboxTableViewController": "Inbox"
        ]
        
        var viewControllers = [UIViewController]()
        var viewController: UIViewController? = nil
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let inboxMessageId = state["inboxMessageId"] as? String

        if let identifier = classToIdentifier[interface] {
            viewController =  storyboard.instantiateViewController(withIdentifier: identifier)
        } else if let inboxMessageId = inboxMessageId, let inboxMessage = MCEInboxDatabase.shared.inboxMessage(withInboxMessageId: inboxMessageId), let inboxViewController = storyboard.instantiateViewController(withIdentifier: "Inbox") as? MCEInboxTableViewController, let messageViewController = inboxViewController.viewController(for: inboxMessage) {
            viewControllers.append(inboxViewController)
            viewController = messageViewController
        } 
        
        guard let realViewController = viewController else {
            return
        }

        viewControllers.append(realViewController)
        
        guard let navigationController = findNavigationController(inWindow: window) else {
            return
        }
        
        if interface != "MainVC" {
            let mainVC = storyboard.instantiateViewController(withIdentifier: "Main")
            viewControllers.insert(mainVC, at: 0)
        }
        
        navigationController.viewControllers = viewControllers
        if let interfaceState = state["interfaceState"] as? Data, let restorableViewController = viewController as? RestorableVC {
            restorableViewController.interfaceState = interfaceState
        }
    }
        
    static func assemble(window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "Main")
        let masterViewController = NavigationVC(rootViewController: mainViewController)
        if UIDevice.current.userInterfaceIdiom == .pad {
            let splitViewController = UISplitViewController()
            let registrationController = storyboard.instantiateViewController(withIdentifier: "Registration")
            let detailViewController = NavigationVC(rootViewController: registrationController)
            splitViewController.viewControllers = [masterViewController, detailViewController]
            detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            window.rootViewController = splitViewController
        } else {
            window.rootViewController = masterViewController
        }
        window.makeKeyAndVisible()
    }
 
    static func findNavigationController(inWindow window: UIWindow) -> UINavigationController? {
        if let splitViewController = window.rootViewController as? UISplitViewController, let navigationViewController = splitViewController.viewControllers.last as? UINavigationController {
            return navigationViewController
        }
        if let navigationController = window.rootViewController as? UINavigationController {
            return navigationController
        }
        return nil
    }
        
    static func state(forWindow window: UIWindow) -> [AnyHashable : Any]? {
        var state = [AnyHashable : Any]()
        guard let appVersion = appVersion else {
            return nil
        }
        state["appVersion"] = appVersion
        guard let navigationController = findNavigationController(inWindow: window) else {
            return nil
        }
        
        guard let visibleViewController = navigationController.visibleViewController else {
            return nil
        }
        
        state["interface"] = String(describing: type(of: visibleViewController))
        if let restorableViewController = visibleViewController as? RestorableVC {
            state["interfaceState"] = restorableViewController.interfaceState
        }
        
        if let inboxViewController = visibleViewController as? MCETemplateDisplay {
            let inboxMessage = inboxViewController.inboxMessage
            state["inboxMessageId"] = inboxMessage?.inboxMessageId
        }
        
        return state
    }
    
    static func restorable(state: NSDictionary) -> Bool {
        return state["interface"] != nil && state["appVersion"] as? String == self.appVersion
    }
}
