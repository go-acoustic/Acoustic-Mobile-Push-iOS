//
//  ContentView.swift
//  TestUI
//
//  Created by Jeremy Buchman on 8/2/19.
//  Copyright © 2019 Jeremy Buchman. All rights reserved.
//

import AcousticMobilePush
import SwiftUI

struct ContentView : View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: VStack {
                    Spacer()
                    Image("logo")
                    Image("campaign")
                    Text("Acoustic Campaign Mobile Sample App")
                    Text("Native SDK v\(MCESdk.shared.sdkVersion())")
                    Spacer()
                }.frame(minWidth: nil, maxWidth: .infinity, maxHeight: 140, alignment: .center), footer: Text("Copyright Acoustic 2021. All rights reserved.")) {
                    NavigationLink(destination: RegistrationView()) {
                        Text("Registration Details")
                    }
                    NavigationLink(destination: InboxView()) {
                        Text("Inbox")
                    }
                    NavigationLink(destination: InAppView()) {
                        Text("In App")
                    }
                    NavigationLink(destination: CustomActionView()) {
                        Text("Custom Actions")
                    }
                    NavigationLink(destination: TestEventView()) {
                        Text("Send Test Events")
                    }
                    NavigationLink(destination: UserAttributeView()) {
                        Text("Send User Attributes")
                    }
                    NavigationLink(destination: GeofenceView()) {
                        Text("Geofences")
                    }
                    NavigationLink(destination: BeaconView()) {
                        Text("iBeacons")
                    }
                }
            }
            .navigationBarTitle(Text("Sample App"), displayMode: .inline)            
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().previewDevice("iPhone SE")
            ContentView().colorScheme(.light).previewDevice("iPhone X")
            ContentView().colorScheme(.dark).previewDevice("iPhone X")
        }

    }
}
#endif
