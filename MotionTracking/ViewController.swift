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
import Charts


class ViewController: UIViewController, ChartViewDelegate {
  
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

    @IBOutlet weak var pieChartshots: PieChartView!
    
    var count = 1
    var readFile = ""
    
    var defensiveDataEntry = PieChartDataEntry(value: 0)
    var driveDataEntry = PieChartDataEntry(value: 0)
    var cutDataEntry = PieChartDataEntry(value: 0)
    var pullDataEntry = PieChartDataEntry(value: 0)
    var sweepDataEntry = PieChartDataEntry(value: 0)
    
    var numberOfDownloadsDataEntries = [PieChartDataEntry]()
    
    
//    var shots = ["Drive", "Defensive", "Cut", "Pull", "Sweep"]
    
    var shots = ["Drive", "Defensive", "Cut", "Pull", "Sweep"]
    
    
    
    @IBOutlet weak var ShotHistoryTable: UITableView!
    
    
    
    //MARK: CreateML framework set-up
    
    // Define some ML Model constants for the recurrent network
      struct ModelConstants {
        static let numOfFeatures = 6
        // Must be the same value you used while training
        static let predictionWindowSize = 120
        // Must be the same value you used while training
        static let sensorsUpdateFrequency = 1.0 / 80.0
        static let hiddenInLength = 20
        static let hiddenCellInLength = 380
      }
    // Initialize the model, layers, and sensor data arrays
      private let classifier = FYP_1()
      private let modelName:String = "ShotClassifier"
    
    
    let accX_final = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let accY_final = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let accZ_final = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let rotX_final = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let rotY_final = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let rotZ_final = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    var currentState = try? MLMultiArray(
        shape: [(ModelConstants.hiddenInLength +
          ModelConstants.hiddenCellInLength) as NSNumber],
        dataType: MLMultiArrayDataType.double)
    

    
    
    

    override func viewDidLoad() {
      super.viewDidLoad()
        
        ShotHistoryTable.delegate = self
        ShotHistoryTable.dataSource = self
        
        pieChartshots.delegate = self
        
      // Do any additional setup after loading the view.
      self.configureWatchKitSession()
        
        
        updateChartData()
        
        
    }
    
    
    
    func updateChartData() {
        
        
        var counts: [String: Int] = [:]
        shots.forEach { counts[$0, default: 0] += 1 }
        
        var names = [String]()
        var values = [Int]()
        
        for (key, value) in counts {
            names.append(key)
            values.append(value)
        }
        
           
        pieChartshots.chartDescription.text = ""
        
        defensiveDataEntry.label = "Defensive"
        let def_index = names.enumerated().filter{ $0.element == "Defensive"}.map{ $0.offset }
        let val_def  = Double(values[def_index[0]]) - 1.0
        defensiveDataEntry.value = val_def
        
        driveDataEntry.label = "Drive"
        let drv_index = names.enumerated().filter{ $0.element == "Drive"}.map{ $0.offset }
        let val_drv  = Double(values[drv_index[0]]) - 1.0
        driveDataEntry.value = val_drv
        
        cutDataEntry.label = "Cut"
        let cut_index = names.enumerated().filter{ $0.element == "Cut"}.map{ $0.offset }
        let val_cut  = Double(values[cut_index[0]]) - 1.0
        cutDataEntry.value = val_cut
        
        pullDataEntry.label = "Pull"
        let pll_index = names.enumerated().filter{ $0.element == "Pull"}.map{ $0.offset }
        let val_pll  = Double(values[pll_index[0]]) - 1.0
        pullDataEntry.value = val_pll
        
        sweepDataEntry.label = "Sweep"
        let swp_index = names.enumerated().filter{ $0.element == "Sweep"}.map{ $0.offset }
        let val_swp  = Double(values[swp_index[0]]) - 1.0
        sweepDataEntry.value = val_swp
        
        numberOfDownloadsDataEntries = [defensiveDataEntry, driveDataEntry, cutDataEntry, pullDataEntry, sweepDataEntry]
        
        
        let chartDataSet = PieChartDataSet(entries: numberOfDownloadsDataEntries)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        self.pieChartshots.legend.enabled = false
        
        chartDataSet.colors = ChartColorTemplates.pastel()
        pieChartshots.data = chartData
        
        
        
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
            
            let rotX = sep[1...120]
            let rotY = sep[123...242]
            let rotZ = sep[245...364]
            let accX = sep[367...486]
            let accY = sep[489...608]
            let accZ = sep[611...730]
            
            print(rotX)
            print(rotY)
            
            let rotX_edit = rotX.doubleArray
            let rotY_edit = rotY.doubleArray
            let rotZ_edit = rotZ.doubleArray
            let accX_edit = accX.doubleArray
            let accY_edit = accY.doubleArray
            let accZ_edit = accZ.doubleArray
            
            print(rotX_edit)
            print(rotX_edit.count)
            
            for j in (0...119) {
                
                self.rotX_final![j] = rotX_edit[j] as NSNumber
                self.rotY_final![j] = rotY_edit[j] as NSNumber
                self.rotZ_final![j] = rotZ_edit[j] as NSNumber
                self.accX_final![j] = accX_edit[j] as NSNumber
                self.accY_final![j] = accY_edit[j] as NSNumber
                self.accZ_final![j] = accZ_edit[j] as NSNumber
                
            }
            
            print(rotX_final as Any)
            
        }
    }
    
    
    func activityPrediction2() -> String? {
        
      // Perform prediction
      let modelPrediction = try? classifier.prediction(
        acceleration_x: accX_final!,
        acceleration_y: accY_final!,
        acceleration_z: accZ_final!,
        gyro_x: rotX_final!,
        gyro_y: rotY_final!,
        gyro_z: rotZ_final!,
        stateIn: currentState!)
    // Update the state vector
      currentState = modelPrediction?.stateOut
    // Return the predicted activity
      return modelPrediction?.label
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
            
            if self.count > 1 {
                
                self.classlabel.text = self.activityPrediction2() ?? "N/A"
                
                shots.append(self.activityPrediction2() ?? "N/A")
                
            }
            
                
            self.count = count + 1
            
            print(shots)

            self.ShotHistoryTable.reloadData()
            
            updateChartData()
            
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



extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected \(shots[indexPath.row]).")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ShotHistoryTable.dequeueReusableCell(withIdentifier: "ShotHistory", for: indexPath)
        cell.textLabel?.text = shots[indexPath.row]
        return cell
    }
    
}


