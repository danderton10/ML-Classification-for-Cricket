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


class ViewController: UIViewController, ChartViewDelegate, UITextFieldDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
    var session: WCSession?
    
    //MARK: ViewController variables
    
    // IBOutlets to connect code to storyboard layout
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var shotlabel: UILabel!
    @IBOutlet weak var classlabel: UILabel!
    @IBOutlet weak var pieChartshots: PieChartView!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var segmentedcontrol: UISegmentedControl!
    @IBOutlet weak var textfield: UITextField!
    
    
    var defensiveDataEntry = PieChartDataEntry(value: 0)
    var driveDataEntry = PieChartDataEntry(value: 0)
    var cutDataEntry = PieChartDataEntry(value: 0)
    var pullDataEntry = PieChartDataEntry(value: 0)
    var sweepDataEntry = PieChartDataEntry(value: 0)
    
    var numberOfDownloadsDataEntries = [PieChartDataEntry]()
    var line_entries = [BarChartDataEntry]()
    
    var count = 1
    var readFile = ""
    var graph = 0
    var status = true
    
    var template_cut = [String]()
    
    
    struct Template {
        
        var accX_template: String = ""
        var accY_template: String = ""
        var accZ_template: String = ""
        var rotX_template: String = ""
        var rotY_template: String = ""
        var rotZ_template: String = ""
        
        init(raw: [String]) {
            
            accX_template = raw[0]
            accY_template = raw[1]
            accZ_template = raw[2]
            rotX_template = raw[3]
            rotY_template = raw[4]
            rotZ_template = raw[5]
            
        }
    }
    

    
    //MARK: CreateML framework set-up
    
    // Define some ML Model constants for the recurrent network
      struct ModelConstants {
        static let numOfFeatures = 6
        // Must be the same value you used while training
        static let predictionWindowSize = 120
        static let sensorsUpdateFrequency = 1.0 / 80.0
        static let hiddenInLength = 20
        static let hiddenCellInLength = 380
      }
    // Initialize the model, layers, and sensor data arrays
      private let classifier = FYP_1()
      private let modelName:String = "ShotClassifier"
    
    
    
    var temp_cut_xg = [String]()
    
    
    
    
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
    

    
    //MARK: Set Up

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pieChartshots.delegate = self
        lineChart.delegate = self
        
        textfield.delegate = self
        
        self.configureWatchKitSession()
        
        updateChartData()
        
        let bottomline = CALayer()
        
        bottomline.frame = CGRect(x: 0, y: textfield.frame.height, width: textfield.frame.width, height: 2)
        
        bottomline.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        
        textfield.borderStyle = .none
        textfield.layer.addSublayer(bottomline)
        
        
    }
    
    // Configure Watch Connection
    func configureWatchKitSession() {

    if WCSession.isSupported() {
      session = WCSession.default
      session?.delegate = self
      session?.activate()
    }
    }
    
    
    //MARK: Chart Functions
    
    
    func updateLineChart(line_entries: [BarChartDataEntry], name: String) {
        
        let set2 = LineChartDataSet(entries: line_entries, label: name)
        set2.colors = [NSUIColor(red: CGFloat(80.0/255), green: CGFloat(33.0/255), blue: CGFloat(222.0/255), alpha: 1)]
        self.lineChart.legend.verticalAlignment = .top
        self.lineChart.legend.horizontalAlignment = .left
        set2.drawCirclesEnabled = false;
        set2.lineWidth = 5.5
        set2.drawValuesEnabled = false
        
        
        let data2 = LineChartData(dataSet: set2)
        lineChart.data = data2
        lineChart.noDataText = "You need to register a shot for this chart to display!"
//        lineChart.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        lineChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        lineChart.drawMarkers = false
        lineChart.rightAxis.enabled = false
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.drawLabelsEnabled = true
        
    }
    
    
    func updateChartData() {
        
        var counts: [String: Int] = [:]
        appDelegate.shots.forEach { counts[$0, default: 0] += 1 }
        
        var names = [String]()
        var values = [Int]()
        
        for (key, value) in counts {
            names.append(key)
            values.append(value)
        }
        
        pieChartshots.chartDescription.text = ""
        pieChartshots.noDataText = "You need to register a shot for this chart to display!"
        
        defensiveDataEntry.label = "Defensive"
        let def_index = names.enumerated().filter{ $0.element == "Defensive"}.map{ $0.offset }
        if def_index.count > 0 {
            let val_def  = Double(values[def_index[0]])
            defensiveDataEntry.value = val_def
        }
        else {defensiveDataEntry.value = 0}
        
        driveDataEntry.label = "Drive"
        let drv_index = names.enumerated().filter{ $0.element == "Drive"}.map{ $0.offset }
        if drv_index.count > 0 {
            let val_drv  = Double(values[drv_index[0]])
            driveDataEntry.value = val_drv
        }
        else {driveDataEntry.value = 0}
        
        cutDataEntry.label = "Cut"
        let cut_index = names.enumerated().filter{ $0.element == "Cut"}.map{ $0.offset }
        if cut_index.count > 0 {
            let val_cut  = Double(values[cut_index[0]])
            cutDataEntry.value = val_cut
        }
        else {cutDataEntry.value = 0}

        pullDataEntry.label = "Pull"
        let pll_index = names.enumerated().filter{ $0.element == "Pull"}.map{ $0.offset }
        if pll_index.count > 0 {
            let val_pll  = Double(values[pll_index[0]])
            pullDataEntry.value = val_pll
        }
        else {pullDataEntry.value = 0}

        sweepDataEntry.label = "Sweep"
        let swp_index = names.enumerated().filter{ $0.element == "Sweep"}.map{ $0.offset }
        if swp_index.count > 0 {
            let val_swp  = Double(values[swp_index[0]])
            sweepDataEntry.value = val_swp
        }
        else {sweepDataEntry.value = 0}

        
        numberOfDownloadsDataEntries = [defensiveDataEntry, driveDataEntry, cutDataEntry, pullDataEntry, sweepDataEntry]
        
        let chartDataSet = PieChartDataSet(entries: numberOfDownloadsDataEntries)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        self.pieChartshots.legend.enabled = false
        chartDataSet.colors = ChartColorTemplates.joyful()
        pieChartshots.data = chartData
        pieChartshots.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        
    }
    
    
    
    //MARK: UI Button Functions

    
    @IBAction func displayXAcc(_ sender: Any) {
        var line = [BarChartDataEntry]()
        for x in 0...119 {
            line.append(BarChartDataEntry(x: Double(x)/80.0, y: appDelegate.accX_edit[x]))
        }
        updateLineChart(line_entries: line, name: "X Acceleration")
    }
    @IBAction func displayYAcc(_ sender: Any) {
        var line = [BarChartDataEntry]()
        for x in 0...119 {
            line.append(BarChartDataEntry(x: Double(x)/80.0, y: appDelegate.accY_edit[x]))
        }
        updateLineChart(line_entries: line, name: "Y Acceleration")
    }
    @IBAction func displayZAcc(_ sender: Any) {
        var line = [BarChartDataEntry]()
        for x in 0...119 {
            line.append(BarChartDataEntry(x: Double(x)/80.0, y: appDelegate.accZ_edit[x]))
        }
        updateLineChart(line_entries: line, name: "Z Acceleration")
    }
    @IBAction func displayXGyro(_ sender: Any) {
        var line = [BarChartDataEntry]()
        for x in 0...119 {
            line.append(BarChartDataEntry(x: Double(x)/80.0, y: appDelegate.rotX_edit[x]))
        }
        updateLineChart(line_entries: line, name: "X Rotation")
    }
    @IBAction func displayYGyro(_ sender: Any) {
        var line = [BarChartDataEntry]()
        for x in 0...119 {
            line.append(BarChartDataEntry(x: Double(x)/80.0, y: appDelegate.rotY_edit[x]))
        }
        updateLineChart(line_entries: line, name: "Y Rotation")
    }
    @IBAction func displayZGyro(_ sender: Any) {
        var line = [BarChartDataEntry]()
        for x in 0...119 {
            line.append(BarChartDataEntry(x: Double(x)/80.0, y: appDelegate.rotZ_edit[x]))
        }
        updateLineChart(line_entries: line, name: "Z Rotation")
    }
    
    
    
    @IBAction func orientationtoggle(_ sender: Any) {
        
        switch segmentedcontrol.selectedSegmentIndex
        {
        case 0:
            appDelegate.orientation[appDelegate.session_no] = "Left Handed"
        case 1:
            appDelegate.orientation[appDelegate.session_no] = "Right Handed"
        default:
            break
        }
        
    }

    
    @IBAction func SaveSession(_ sender: Any) {
        
        let date = Date()
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "HH:mm E, d MMM y"
        print(formatter1.string(from: date))
        appDelegate.endtimes.append(formatter1.string(from: date))
        
        let c = Double(appDelegate.shots.count)
        
        if appDelegate.percentaccuracy > 0.0 {
            let acc = Double((Double(appDelegate.percentaccuracy/c))*100.0)
            print(acc)
            appDelegate.overallaccuracy.append(Double(acc))
        }
        else {appDelegate.overallaccuracy.append(0.0)}
        
        status = true
        
        
        let image = pieChartshots.getChartImage(transparent: false)!
        let string = image.toPngString() // it will convert UIImage to string
        appDelegate.image.append(string!)
        
        
        if appDelegate.shots.count > 0 {
            appDelegate.session_no += 1
        }
        
        print(appDelegate.session_no)
        print(appDelegate.starttimes)
        
        appDelegate.stats.removeAll()
        appDelegate.accX_graph.removeAll()
        appDelegate.accY_graph.removeAll()
        appDelegate.accZ_graph.removeAll()
        appDelegate.rotX_graph.removeAll()
        appDelegate.rotY_graph.removeAll()
        appDelegate.rotZ_graph.removeAll()
        
        appDelegate.shots.removeAll()
        print(appDelegate.shots)
        
        appDelegate.firstclick = true
        
        appDelegate.name.append(textfield.text!)
        print(appDelegate.name)
        
        
        updateChartData()
        self.shotlabel.text = String(0)
        
        if let validSession = self.session, validSession.isReachable {
            print("Hello")
          let data: [String: Any] = ["iPhone": "Data from iPhone" as Any] // Create your Dictionay as per uses
          validSession.sendMessage(data, replyHandler: nil, errorHandler: { error in
              // catch any errors here
              print(error)
              }
          )}
        
    }
    


    //MARK: Predicition Functions
    
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

            appDelegate.rotX_edit = rotX.doubleArray
            appDelegate.rotY_edit = rotY.doubleArray
            appDelegate.rotZ_edit = rotZ.doubleArray
            appDelegate.accX_edit = accX.doubleArray
            appDelegate.accY_edit = accY.doubleArray
            appDelegate.accZ_edit = accZ.doubleArray
    
            for j in (0...119) {
                
                self.rotX_final![j] = appDelegate.rotX_edit[j] as NSNumber
                self.rotY_final![j] = appDelegate.rotY_edit[j] as NSNumber
                self.rotZ_final![j] = appDelegate.rotZ_edit[j] as NSNumber
                self.accX_final![j] = appDelegate.accX_edit[j] as NSNumber
                self.accY_final![j] = appDelegate.accY_edit[j] as NSNumber
                self.accZ_final![j] = appDelegate.accZ_edit[j] as NSNumber
                
            }
            
            print(rotX_final as Any)
            
            appDelegate.rotX_graph.append(appDelegate.rotX_edit)
            appDelegate.rotY_graph.append(appDelegate.rotY_edit)
            appDelegate.rotZ_graph.append(appDelegate.rotZ_edit)
            appDelegate.accX_graph.append(appDelegate.accX_edit)
            appDelegate.accY_graph.append(appDelegate.accY_edit)
            appDelegate.accZ_graph.append(appDelegate.accZ_edit)
            
            PerformanceParameters()
            
            graph = graph + 1
            
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
    
    
    // This function is called when you click return key in the text field.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        print("textFieldShouldReturn")
        
        // Resign the first responder from textField to close the keyboard.
        textField.resignFirstResponder()
        

        
        
        return true
    }
    
    
    
    
    func PerformanceParameters() {
        
        // BAT SPEED
        let g_y_max_av = appDelegate.rotY_edit.max()!
        let g_z_max_av = appDelegate.rotZ_edit.max()!
        let omega = sqrt(pow(g_y_max_av, 2) + pow(g_z_max_av, 2))
        let RacketSpeedAverage = omega*0.769
        
        
        // SHOT QUALITY
        
        var temp_defensive = getCSVData(from: "Template_Defensive")
        var temp_drive = getCSVData(from: "Template_Drive")
        var temp_cut = getCSVData(from: "Template_Cut")
        var temp_pull = getCSVData(from: "Template_Pull")
        var temp_sweep = getCSVData(from: "Template_Sweep")
        
        var temp_def = [[Double]]()
        var temp_drv = [[Double]]()
        var temp_ct = [[Double]]()
        var temp_pll = [[Double]]()
        var temp_swp = [[Double]]()
        
        for x in 0...5 {
            temp_def.append(temp_defensive[x].doubleArray)
            temp_drv.append(temp_drive[x].doubleArray)
            temp_ct.append(temp_cut[x].doubleArray)
            temp_pll.append(temp_pull[x].doubleArray)
            temp_swp.append(temp_sweep[x].doubleArray)
        }
        
        var consistency = [0.0,0.0,0.0,0.0,0.0,0.0]
        print(temp_swp[0])
            
        for i in (0...119) {
            consistency[0] = consistency[0] + sqrt(pow((appDelegate.accX_edit[i])-Double((temp_drv[0].index(0, offsetBy: i))),2))
            consistency[1] = consistency[1] + sqrt(pow((appDelegate.accY_edit[i])-Double((temp_drv[1].index(0, offsetBy: i))),2))
            consistency[2] = consistency[2] + sqrt(pow((appDelegate.accZ_edit[i])-Double((temp_drv[2].index(0, offsetBy: i))),2))
            consistency[3] = consistency[3] + sqrt(pow((appDelegate.rotX_edit[i])-Double((temp_drv[3].index(0, offsetBy: i))),2))
            consistency[4] = consistency[4] + sqrt(pow((appDelegate.rotY_edit[i])-Double((temp_drv[4].index(0, offsetBy: i))),2))
            consistency[5] = consistency[5] + sqrt(pow((appDelegate.rotZ_edit[i])-Double((temp_drv[5].index(0, offsetBy: i))),2))
        }
        
        print(consistency[0])
        

        // Values need taking from Python Code
        
        consistency[0] = ((500.0-consistency[0])/400.0)*5.0 + 5.0
        consistency[1] = ((500.0-consistency[1])/400.0)*5.0 + 5.0
        consistency[2] = ((500.0-consistency[2])/400.0)*5.0 + 5.0
        consistency[3] = ((500.0-consistency[3])/400.0)*5.0 + 5.0
        consistency[4] = ((500.0-consistency[4])/400.0)*5.0 + 5.0
        consistency[5] = ((500.0-consistency[5])/400.0)*5.0 + 5.0
        
        let sumArray = consistency.reduce(0, +)
        let avgconsistency = sumArray / Double(consistency.count)

        let features = [RacketSpeedAverage,avgconsistency,appDelegate.accX_edit.max()!,appDelegate.accX_edit.max()!]
        appDelegate.stats.append(features)
    }
    
    
    func getCSVData(from csvName: String) -> [[String]] {
        
        var temp_xa = [String]()
        var temp_ya = [String]()
        var temp_za = [String]()
        var temp_xg = [String]()
        var temp_yg = [String]()
        var temp_zg = [String]()
        
        guard let filePath = Bundle.main.path(forResource: csvName, ofType: "csv") else {
            return []
        }
        
        var data = ""
        do {
            data = try String(contentsOfFile: filePath)
        } catch {
            print(error)
            return []
        }
        
        var rows = data.components(separatedBy: "\n")
        rows.removeFirst()
        
        for row in rows {
            
            let csvColumns = row.components(separatedBy: ",")
            temp_xa.append(csvColumns[0])
            temp_ya.append(csvColumns[0])
            temp_za.append(csvColumns[0])
            temp_xg.append(csvColumns[0])
            temp_yg.append(csvColumns[0])
            temp_zg.append(csvColumns[0])
        }
        
        let csvToStruct = [temp_xa, temp_ya, temp_za, temp_xg, temp_yg, temp_zg]
        
        return csvToStruct
    }


    
    // This function is called when you input text in the textView.
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
            
            print("textView.")
            
            print("input text is : \(text)")
            
            // If user press return key in the keyboard.
            if("\n" == text){
                
                // Resign first responder from UITextView to close the keyboard.
                textView.resignFirstResponder()
                
                return false
            }
            
            return true
        }
    
    
    
    
}




//MARK: Watch Session Delegate


extension ViewController: WCSessionDelegate {
  
  func sessionDidBecomeInactive(_ session: WCSession) {}
  
  func sessionDidDeactivate(_ session: WCSession) {}
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    print("received message: \(message)")
      DispatchQueue.main.async { [self] in
          if (message["watch"] as? String) != nil {
          
              self.shotlabel.text = String(0)
              

              let date = Date()
              let formatter1 = DateFormatter()
              formatter1.dateFormat = "HH:mm E, d MMM y"
              print(formatter1.string(from: date))
              appDelegate.endtimes.append(formatter1.string(from: date))
              
              
              let image = pieChartshots.getChartImage(transparent: false)!
              let string = image.toPngString() // it will convert UIImage to string
              appDelegate.image.append(string!)
              
              appDelegate.session_no += 1
              
              appDelegate.stats.removeAll()
              appDelegate.accX_graph.removeAll()
              appDelegate.accY_graph.removeAll()
              appDelegate.accZ_graph.removeAll()
              appDelegate.rotX_graph.removeAll()
              appDelegate.rotY_graph.removeAll()
              appDelegate.rotZ_graph.removeAll()
              
              appDelegate.shots.removeAll()
              print(appDelegate.shots)
              
              appDelegate.firstclick = true
              
              updateChartData()
              status = true
          }
          
        if let value = message["count"] as? String {
          self.shotlabel.text = value
        }
          
        if let value = message["on"] as? String {
          self.StatusLabel.text = value
            
            if status == true {
                let date = Date()
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "HH:mm E, d MMM y"
                print(formatter1.string(from: date))
                appDelegate.starttimes.append(formatter1.string(from: date))
            }
            
            appDelegate.firstclick = true
            status = false
            appDelegate.orientation.append("Right Handed")
        }
          
        if let value = message["off"] as? String {
            self.StatusLabel.text = value
          }
          
        if let value = message["array"] as? String {
            
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
            
            activityPrediction()
            
            if readFile.isEmpty == false {
                
            self.classlabel.text = self.activityPrediction2() ?? "N/A"
            
            appDelegate.shots.append(self.activityPrediction2() ?? "N/A")
            
            updateChartData()
    
            line_entries.removeAll()
            
            for x in 0...119 {
                line_entries.append(BarChartDataEntry(x: Double(x)/80.0, y: appDelegate.rotX_edit[x]))
            }
            updateLineChart(line_entries: line_entries, name: "X Rotation")
            }
            
            print(appDelegate.shots)
            print(appDelegate.stats)

            self.count = count + 1
        
          }
    }
  }
    
}



//MARK: Other Extensions


extension Collection where Iterator.Element == String {
    var doubleArray: [Double] {
        return compactMap{ Double($0) }
    }
    var floatArray: [Float] {
        return compactMap{ Float($0) }
    }
}


extension UILabel {
    @IBInspectable
    var rotation: Int {
        get {
            return 0
        } set {
            let radians = CGFloat(CGFloat(Double.pi) * CGFloat(newValue) / CGFloat(180.0))
            self.transform = CGAffineTransform(rotationAngle: radians)
        }
    }
}


extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}


extension UIImage {
    func toPngString() -> String? {
        let data = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
}


