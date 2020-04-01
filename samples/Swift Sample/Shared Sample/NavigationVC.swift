// Copyright (c) 2019. Acoustic, L.P. All rights reserved.
// NOTICE: This file contains material that is confidential and proprietary to Acoustic, L.P. and/or other developers. No license is granted under any intellectual or industrial property rights of Acoustic, L.P. except as may be provided in an agreement with Acoustic, L.P. Any unauthorized copying or distribution of content from this file is prohibited.

import UIKit

// This works for now since there isn't a point to supporting multiple windows in this sample app.
// When multiple window support is desired, this functionality should move into the scene
class NavigationVC: UINavigationController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColor()
    }
    
    func updateColor() {
        UIApplication.shared.keyWindow?.tintColor = .tint
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateColor()
    }
}
