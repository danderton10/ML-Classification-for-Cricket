/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This application's view controller.
 */


import UIKit
import WatchConnectivity
import os.log

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

    
    var count = 1

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
            var readFile = ""
            do {
               readFile = try String(contentsOf: fileUrl)
            } catch let error as NSError {
               print(error)
            }
            print (readFile)
            
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
