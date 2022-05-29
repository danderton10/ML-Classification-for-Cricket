/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This class is responsible for managing interactions with the interface.
 */

import WatchKit
import Foundation
import Dispatch
import WatchConnectivity
import os.log

class InterfaceController: WKInterfaceController, WorkoutManagerDelegate {
    
    let watchDelegate = WKExtension.shared().delegate as! ExtensionDelegate
    
    // MARK: Properties

    let workoutManager = WorkoutManager()
    var active = false
    
    let session = WCSession.default
    
    var gravityStr = ""
    var userAccelStr = ""
    var rotationRateStr = ""
    var ArrayOfSampleData = String()
    var isWorkingOut = false


    // MARK: Interface Properties
    
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var gravityLabel: WKInterfaceLabel!
    @IBOutlet weak var userAccelLabel: WKInterfaceLabel!
    @IBOutlet weak var rotationLabel: WKInterfaceLabel!
    @IBOutlet weak var shotCountLabel: WKInterfaceLabel!
    
    
    // MARK: Initialization
    
    override init() {
        super.init()
        workoutManager.delegate = self
    }


    override func awake(withContext context: Any?) {
      super.awake(withContext: context)
      // Configure interface objects here.
      session.delegate = self
      session.activate()
    }
    
    
    override func willActivate() {
        super.willActivate()
        active = true
        // On re-activation, update with the cached values.
        updateLabels()
    }

    override func didDeactivate() {
        super.didDeactivate()
        active = false
    }

    
    @IBAction func SessionToggle() {
        isWorkingOut = !isWorkingOut 
        if isWorkingOut{
            titleLabel.setText("Tracking...")
            workoutManager.startWorkout()
            let on: [String: Any] = ["on": "Tracking ..." as Any]
            session.sendMessage(on, replyHandler: nil, errorHandler: nil)
            
        } else {
            titleLabel.setText("Stopped Recording")
            workoutManager.stopWorkout()
            let off: [String: Any] = ["off": "Stopped Recording" as Any]
            session.sendMessage(off, replyHandler: nil, errorHandler: nil)
        }
    }
    
    
    @IBAction func tapSendToiPhone() {
        
        watchDelegate.shotCount = 0
        
        self.shotCountLabel.setText("Shot Count: \(watchDelegate.shotCount)")
        self.gravityLabel.setText("")
        self.userAccelLabel.setText("")
        self.rotationLabel.setText("")
      let data: [String: Any] = ["watch": "data from watch" as Any] //Create your dictionary as per uses
      session.sendMessage(data, replyHandler: nil, errorHandler: nil)
    }
    
    
    func shotCountonPhone() {
        let count: [String: Any] = ["count": "\(watchDelegate.shotCount)" as Any] //Create your dictionary as per uses
      let array: [String: Any] = ["array": "\(ArrayOfSampleData)" as Any]
      session.sendMessage(count, replyHandler: nil, errorHandler: nil)
        session.sendMessage(array, replyHandler: nil, errorHandler: nil)

    }
    
    
    // MARK: WorkoutManagerDelegate
    func didUpdateMotion(_ manager: WorkoutManager, gravityStr: String, rotationRateStr: String, userAccelStr: String) {
        DispatchQueue.main.async {
            self.gravityStr = gravityStr
            self.userAccelStr = userAccelStr
            self.rotationRateStr = rotationRateStr
            self.updateLabels();
        }
    }
    
    
    func didUpdateshotCount(_ manager: WorkoutManager, shotCount: Int, ArrayOfSampleData: String) {
        /// Serialize the property access and UI updates on the main queue.
        DispatchQueue.main.async {
            
            self.watchDelegate.shotCount = shotCount
            self.ArrayOfSampleData = ArrayOfSampleData
            self.updateLabels()
            self.shotCountonPhone()
        }
    }
    
    
    // MARK: Convenience
    func updateLabels() {
        if active {
            gravityLabel.setText(gravityStr)
            userAccelLabel.setText(userAccelStr)
            rotationLabel.setText(rotationRateStr)
            shotCountLabel.setText("Shot Count: \(watchDelegate.shotCount)")
        }
    }
}



extension InterfaceController: WCSessionDelegate {
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    print("received data: \(message)")
  }
    
}
