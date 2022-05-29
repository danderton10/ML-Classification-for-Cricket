/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This application delegate.
 */

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
//    var shots = ["Defensive", "Cut", "Drive"]
    
    var shots = [String]()
    
    var rotX_edit = [Double]()
    var rotY_edit = [Double]()
    var rotZ_edit = [Double]()
    
    var accX_edit = [Double]()
    var accY_edit = [Double]()
    var accZ_edit = [Double]()
}

