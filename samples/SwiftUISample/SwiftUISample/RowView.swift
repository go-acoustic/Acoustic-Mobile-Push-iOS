//
//  RowView.swift
//  SwiftUISample
//
//  Created by Jeremy Buchman on 8/2/19.
//  Copyright © 2019 Jeremy Buchman. All rights reserved.
//

import SwiftUI

struct RowView: View {
    var left: String
    var right: String
    var body: some View {
        HStack {
            Text(left)
            Spacer()
            Text(right).foregroundColor(Color.secondary)
        }
        .frame(minWidth: nil, maxWidth: .infinity)
    }
}
