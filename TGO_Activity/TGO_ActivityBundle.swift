//
//  TGO_ActivityBundle.swift
//  TGO_Activity
//
//  Created by Brooklyn Daines on 9/19/25.
//

import WidgetKit
import SwiftUI

//@main
struct TGO_ActivityBundle: WidgetBundle {
    var body: some Widget {
        TGO_Activity()
        TGO_ActivityControl()
        TGO_ActivityLiveActivity()
    }
}
