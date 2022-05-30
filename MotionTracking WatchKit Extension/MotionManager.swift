/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This class manages the CoreMotion interactions and 
         provides a delegate to indicate changes in data.
 */

import Foundation
import CoreMotion
import WatchKit
import os.log
import WatchConnectivity
import CoreML
/**
 `MotionManagerDelegate` exists to inform delegates of motion changes.
 These contexts can be used to enable application specific behavior.
 */
protocol MotionManagerDelegate: AnyObject {
    func didUpdateMotion(_ manager: MotionManager, gravityStr: String, rotationRateStr: String, userAccelStr: String)
    func didUpdateshotCount(_ manager: MotionManager, shotCount: Int, ArrayOfSampleData:String)
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}


class MotionManager {
    
    let watchDelegate = WKExtension.shared().delegate as! ExtensionDelegate
    
    
    // MARK: Properties & Constants
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .left
    let session = WCSession.default

    // These constants were derived from data and are tuned for the shot detection
    let accThreshold = 2.0 // Acceleration magnitude threshold (2g)
    var resetThreshold = 0.0 // counter variable to to ensure minimum distance in time between shots
    
    // The app is using 80hz data and the buffer is going to hold 1.5s worth of data.
    let sampleInterval = 1.0 / 80
    let magnitude_buffer = RunningBuffer(size: 120)
    
    weak var delegate: MotionManagerDelegate?
    
    var gravityStr = ""
    var rotationRateStr = ""
    var userAccelStr = ""
    var ArrayOfSampleData = String()
    
    var i = 0
    var i_detection = 0
    var recentDetection = false
    
    var x_gyro = [Double]()
    var y_gyro = [Double]()
    var z_gyro = [Double]()
    var x_acc = [Double]()
    var y_acc = [Double]()
    var z_acc = [Double]()



    // MARK: Initialization
    
    init() {
        // Serial queue for sample handling and calculations.
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
    }

    
    // MARK: Motion Manager

    func startUpdates() {
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        
        os_log("Start Updates");

        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            if deviceMotion != nil {
                self.processDeviceMotion(deviceMotion!)
            }
        }
    }

    func stopUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
    }

    
    // MARK: Motion Processing
    
    func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
        gravityStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                            deviceMotion.gravity.x,
                            deviceMotion.gravity.y,
                            deviceMotion.gravity.z)
        userAccelStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                           deviceMotion.userAcceleration.x,
                           deviceMotion.userAcceleration.y,
                           deviceMotion.userAcceleration.z)
        rotationRateStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                              deviceMotion.rotationRate.x,
                              deviceMotion.rotationRate.y,
                              deviceMotion.rotationRate.z)
        
        
        self.x_gyro.append(Double(deviceMotion.rotationRate.x))
        self.y_gyro.append(Double(deviceMotion.rotationRate.y))
        self.z_gyro.append(Double(deviceMotion.rotationRate.z))
        self.x_acc.append(Double(deviceMotion.userAcceleration.x))
        self.y_acc.append(Double(deviceMotion.userAcceleration.y))
        self.z_acc.append(Double(deviceMotion.userAcceleration.z))
        self.i += 1
        
        let accmagnitude = sqrt(pow(deviceMotion.userAcceleration.x, 2) + pow(deviceMotion.userAcceleration.y, 2) + pow(deviceMotion.userAcceleration.z, 2))
        
        magnitude_buffer.addSample(accmagnitude)

        if !magnitude_buffer.isFull() {return}
        
        if (accmagnitude > accThreshold) {
            incrementShotCountAndUpdateDelegate()
            i_detection = self.i
        }
        
        if (recentDetection && self.i > i_detection+60) {
            recentDetection = false
            magnitude_buffer.reset()
            
            var ArrayOfSampleData2 = [[Double]](repeating: [Double](repeating: 0, count: 1), count: 6)
            
            let xg_shot = self.x_gyro[(i_detection-60)...(i_detection+60)]
            let yg_shot = self.y_gyro[(i_detection-60)...(i_detection+60)]
            let zg_shot = self.z_gyro[(i_detection-60)...(i_detection+60)]
            let xa_shot = self.x_acc[(i_detection-60)...(i_detection+60)]
            let ya_shot = self.y_acc[(i_detection-60)...(i_detection+60)]
            let za_shot = self.z_acc[(i_detection-60)...(i_detection+60)]
            print(zg_shot)

            ArrayOfSampleData2[0].append(contentsOf: xg_shot)
            ArrayOfSampleData2[1].append(contentsOf: yg_shot)
            ArrayOfSampleData2[2].append(contentsOf: zg_shot)
            ArrayOfSampleData2[3].append(contentsOf: xa_shot)
            ArrayOfSampleData2[4].append(contentsOf: ya_shot)
            ArrayOfSampleData2[5].append(contentsOf: za_shot)
            
            
            let encoded = try! JSONEncoder().encode(ArrayOfSampleData2)
            ArrayOfSampleData = String(data: encoded, encoding: .utf8)!
            print(ArrayOfSampleData)
            print("Data Array Formulated")
                
        }
        
        
        let timestamp = Date().millisecondsSince1970
        
        os_log("Motion: %@, %@, %@, %@, %@, %@, %@, %@, %@, %@",
               String(timestamp),
               String(deviceMotion.gravity.x),
               String(deviceMotion.gravity.y),
               String(deviceMotion.gravity.z),
               String(deviceMotion.userAcceleration.x),
               String(deviceMotion.userAcceleration.y),
               String(deviceMotion.userAcceleration.z),
               String(deviceMotion.rotationRate.x),
               String(deviceMotion.rotationRate.y),
               String(deviceMotion.rotationRate.z))
        
        updateMetricsDelegate();
    }

    
    
    // MARK: Data and Delegate Management
    
    
    func resetAllState() {
        magnitude_buffer.reset()

        watchDelegate.shotCount = 0
        recentDetection = false

        updateShotDelegate()
    }
    
    func incrementShotCountAndUpdateDelegate() {
        if (!recentDetection) {
            
            watchDelegate.shotCount += 1
            recentDetection = true
            print("Updated Shot Count: \(watchDelegate.shotCount)")
            updateShotDelegate()
        }
    }

    func updateShotDelegate() {
        delegate?.didUpdateshotCount(self, shotCount: watchDelegate.shotCount, ArrayOfSampleData: ArrayOfSampleData)
    }
    
    
    func updateMetricsDelegate() {
        delegate?.didUpdateMotion(self,gravityStr:gravityStr, rotationRateStr: rotationRateStr, userAccelStr: userAccelStr)
    }

}
