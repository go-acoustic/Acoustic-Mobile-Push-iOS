//
//  GeofenceView.swift
//  SwiftUISample
//
//  Created by Jeremy Buchman on 8/2/19.
//  Copyright © 2019 Jeremy Buchman. All rights reserved.
//

import SwiftUI

struct GeofenceView: View {
    var body: some View {
        Text("Geofences go here")
    }
}

#if DEBUG
struct GeofenceView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            GeofenceView().previewDevice("iPhone SE")
            GeofenceView().colorScheme(.light)
            GeofenceView().colorScheme(.dark)
        }

    }
}
#endif
