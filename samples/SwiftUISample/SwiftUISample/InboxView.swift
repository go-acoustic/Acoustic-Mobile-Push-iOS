//
//  InboxView.swift
//  SwiftUISample
//
//  Created by Jeremy Buchman on 8/2/19.
//  Copyright © 2019 Jeremy Buchman. All rights reserved.
//

import SwiftUI


struct InboxView: View {
    var body: some View {
        Text("Inbox goes here")
    }
}

#if DEBUG
struct InboxView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            InboxView().previewDevice("iPhone SE")
            InboxView().colorScheme(.light)
            InboxView().colorScheme(.dark)
        }

    }
}
#endif
