//
//  CustomActionView.swift
//  SwiftUISample
//
//  Created by Jeremy Buchman on 8/2/19.
//  Copyright © 2019 Jeremy Buchman. All rights reserved.
//

import SwiftUI

struct CustomActionView: View {
    var body: some View {
        Text("Custom Actions go here")
    }
}

#if DEBUG
struct CustomActionView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            CustomActionView().previewDevice("iPhone SE")
            CustomActionView().colorScheme(.light)
            CustomActionView().colorScheme(.dark)
        }

    }
}
#endif
