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
import os.log
import AcousticMobilePush

@available(macCatalyst 13.0, iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        if window == nil {
            window = UIWindow(windowScene: windowScene)
        }
        
        guard let window = window else {
            return
        }
        
        StateController.assemble(window: window)
        var userActivity = session.scene?.userActivity
        if userActivity == nil {
            userActivity = session.stateRestorationActivity
        }
        
        if let userActivity = userActivity, let userInfo = userActivity.userInfo as NSDictionary? {
            StateController.restore(state: userInfo, toWindow: window)
        } else {
            userActivity = NSUserActivity(activityType: "co.acoustic.mobilepush")
        }
        
        scene.userActivity = userActivity
        
        if let urlContext = connectionOptions.urlContexts.first {
            print("URL delivered to scene(,willConnectTo:,connectionOptions:)")
            displayCustom(url: urlContext.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let urlContext = URLContexts.first {
            print("URL delivered to scene(,openURLContexts:)")
            displayCustom(url: urlContext.url)
            
        }
    }
    
    func displayCustom(url: URL) {
        let controller = UIAlertController(title: "Custom URL Clicked", message: url.absoluteString, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
            
        }))
        window?.rootViewController?.present(controller, animated: true, completion: {
            
        })
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        guard let windowScene = scene as? UIWindowScene, let window = window else {
            return nil
        }
        
        if windowScene.userActivity == nil {
            windowScene.userActivity = NSUserActivity(activityType: "co.acoustic.mobilepush")
        }
        
        guard let state = StateController.state(forWindow: window) else {
            return nil
        }
        
        scene.userActivity?.userInfo = state
        return windowScene.userActivity
    }
}

