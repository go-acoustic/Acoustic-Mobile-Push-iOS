//
//  UserAttributeView.swift
//  SwiftUISample
//
//  Created by Jeremy Buchman on 8/2/19.
//  Copyright © 2019 Jeremy Buchman. All rights reserved.
//

import SwiftUI

struct UserAttributeView: View {
    var body: some View {
        Text("User Attributes go here")
    }
}

#if DEBUG
struct UserAttributeView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            UserAttributeView().previewDevice("iPhone SE")
            UserAttributeView().colorScheme(.light)
            UserAttributeView().colorScheme(.dark)
        }

    }
}
#endif
