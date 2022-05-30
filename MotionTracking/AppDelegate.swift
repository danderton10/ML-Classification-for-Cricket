/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This application delegate.
 */

import UIKit
import Charts

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
    
    var rotX_graph = [[Double]]()
    var rotY_graph = [[Double]]()
    var rotZ_graph = [[Double]]()
    var accX_graph = [[Double]]()
    var accY_graph = [[Double]]()
    var accZ_graph = [[Double]]()
    
    var stats = [[Double]]()
    
    var session_no = 0
    var starttimes = [String]()
    var endtimes = [String]()
    
    var image = [String]()
    
    var firstclick = true
    
    var percentaccuracy = 0.0
    
    var overallaccuracy = [Double]()
    
    
}

