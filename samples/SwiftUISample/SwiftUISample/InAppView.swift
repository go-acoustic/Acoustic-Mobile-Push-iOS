//
//  InAppView.swift
//  SwiftUISample
//
//  Created by Jeremy Buchman on 8/2/19.
//  Copyright © 2019 Jeremy Buchman. All rights reserved.
//

import SwiftUI

struct InAppView: View {
    var body: some View {
        Text("InApp goes here")
    }
}

#if DEBUG
struct InAppView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            InAppView().previewDevice("iPhone SE")
            InAppView().colorScheme(.light)
            InAppView().colorScheme(.dark)
        }

    }
}
#endif
