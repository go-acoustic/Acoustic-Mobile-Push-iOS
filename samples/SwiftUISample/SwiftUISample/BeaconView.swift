//
//  BeaconView.swift
//  SwiftUISample
//
//  Created by Jeremy Buchman on 8/2/19.
//  Copyright © 2019 Jeremy Buchman. All rights reserved.
//

import SwiftUI

struct BeaconView: View {
    var body: some View {
        Text("Beacons go here")
    }
}

#if DEBUG
struct BeaconView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            BeaconView().previewDevice("iPhone SE")
            BeaconView().colorScheme(.light)
            BeaconView().colorScheme(.dark)
        }

    }
}
#endif
