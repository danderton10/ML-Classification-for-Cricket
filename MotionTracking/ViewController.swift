/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This application's view controller.
 */


import UIKit
import WatchConnectivity
import os.log
import CoreML


class ViewController: UIViewController {
  
  var session: WCSession?
    
    // IBOutlets to connect code to storyboard layout
    // messageLabel to display data transfer status of a shot
    @IBOutlet weak var messageLabel: UILabel!
    // StatusLabel to display recording status of a session
    @IBOutlet weak var StatusLabel: UILabel!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var shotlabel: UILabel!
    
    
    @IBOutlet weak var datasent: UILabel!
    //    Initialize the label that will get updated
    @IBOutlet weak var classlabel: UILabel!

    
    var count = 1
    var readFile = ""
    
    
    
    
    
    
    //MARK: CreateML framework set-up
    
    // Define some ML Model constants for the recurrent network
      struct ModelConstants {
        static let numOfFeatures = 6
        // Must be the same value you used while training
        static let predictionWindowSize = 120
        // Must be the same value you used while training
        static let sensorsUpdateFrequency = 1.0 / 80.0
        static let hiddenInLength = 20
        static let hiddenCellInLength = 200
      }
    // Initialize the model, layers, and sensor data arrays
      private let classifier = ShotClassifier()
      private let modelName:String = "ShotClassifier"
    
    
    let accX = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let accY = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let accZ = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    var rotX = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let rotY = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let rotZ = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    var currentState = try? MLMultiArray(
        shape: [(ModelConstants.hiddenInLength +
          ModelConstants.hiddenCellInLength) as NSNumber],
        dataType: MLMultiArrayDataType.double)
    
    
    

    
    
    
    

    override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view.
      self.configureWatchKitSession()
    }
    
    // Configure Watch Connection
    func configureWatchKitSession() {

    if WCSession.isSupported() {
      session = WCSession.default
      session?.delegate = self
      session?.activate()
    }
    }
    
    
    @IBAction func tapSendDataToWatch(_ sender: Any) {
      
      if let validSession = self.session, validSession.isReachable {
          print("Hello")
        let data: [String: Any] = ["iPhone": "Data from iPhone" as Any] // Create your Dictionay as per uses
        validSession.sendMessage(data, replyHandler: nil, errorHandler: { error in
            // catch any errors here
            print(error)
            }
        )}
    }
    
    
    func activityPrediction() {
        
        print (readFile)
        
        print(readFile.count)
        
        let sep = readFile.components(separatedBy: ",")
        
        print(sep.count)
        
        
        if (sep.count > 700) {
            
            let rotX = sep[1...119]
            let rotY = sep[122...240]
            
            print(rotX)
            print(rotY)
            
            let rotXedit = rotX.doubleArray
            
            print(rotXedit)
            
        }
        

        
//        let range = readFile.startIndex
//        print(readFile[range])
//
//        let index = readFile.index(after: readFile.startIndex)
//        print(readFile[index])
        
//        let text = readFile[0]
        
//        let decoded = try! JSONDecoder().decode([readFile].self, from: readFile)
        
        
//        let testxacc = readFile[0...120]
        
        
//      // Perform prediction
//      let modelPrediction = try? classifier.prediction(
//        acceleration_x: accX!,
//        acceleration_y: accY!,
//        acceleration_z: accZ!,
//        gyro_x: rotX!,
//        gyro_y: rotY!,
//        gyro_z: rotZ!,
//        stateIn: currentState!)
//    // Update the state vector
//      currentState = modelPrediction?.stateOut
//    // Return the predicted activity
//      return modelPrediction?.label
    }
    
    
}



// WCSession delegate functions
extension ViewController: WCSessionDelegate {
  
  func sessionDidBecomeInactive(_ session: WCSession) {
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
  }
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    print("received message: \(message)")
      DispatchQueue.main.async { [self] in
      if let shotcount = message["watch"] as? String {
        self.label.text = shotcount
      }
        if let value = message["count"] as? String {
          self.shotlabel.text = value
        }
        if let value = message["on"] as? String {
          self.StatusLabel.text = value
        }
        if let value = message["off"] as? String {
            self.StatusLabel.text = value
          }
        if let value = message["array"] as? String {
            self.datasent.text = "Data Array Received"
            
            let fileName = "shot \(self.count)"
            self.count = count + 1
            let documentDirectoryUrl = try! FileManager.default.url(
               for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
            )
            let fileUrl = documentDirectoryUrl.appendingPathComponent(fileName).appendingPathExtension("txt")
            // prints the file path
            print("File path \(fileUrl.path)")
            do {
               try value.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
               print (error)
            }
            
            do {
               readFile = try String(contentsOf: fileUrl)
            } catch let error as NSError {
               print(error)
            }
            
//            self.classlabel.text = self.activityPrediction() ?? "N/A"
            
            activityPrediction()
            
          }

    }
  }
    

    
    
    
    private func session(_ session: WCSession, didReceiveMessageData messageData: [Data : Any]) {
      print("received data array: \(messageData)")
      DispatchQueue.main.async {
//        if let value = messageData["watch"] as? String {
          self.datasent.text = "Data Array Received"
        }
//      }
    }
    
}


extension Collection where Iterator.Element == String {
    var doubleArray: [Double] {
        return compactMap{ Double($0) }
    }
    var floatArray: [Float] {
        return compactMap{ Float($0) }
    }
}


