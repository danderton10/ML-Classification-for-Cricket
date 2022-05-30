//
//  TableShowViewController.swift
//  SwingWatch
//
//  Created by Dan Anderton on 29/05/2022.
//  Copyright © 2022 Apple Inc. All rights reserved.
//

import UIKit
import Charts

class TableShowViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Variables
    
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var accuracy: UILabel!
    @IBOutlet weak var shot: UILabel!
    
    var contactIndex = 0
    

    // MARK: - Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tablecounter = Array(stride(from: 1, through: appDelegate.shots.count, by: 1))
        
        shot.text = "Shot \(tablecounter[contactIndex]): \(appDelegate.shots[contactIndex])"
        
        var line_entries = [BarChartDataEntry]()
        
        let axis = appDelegate.rotX_graph[contactIndex]
        
        for x in 0...119 {
            line_entries.append(BarChartDataEntry(x: Double(x)/80.0, y: axis[x]))
        }
        
        updateLineChart(line_entries: line_entries, name: "X Rotation")
    }
    
    
    
    // MARK: - Line Chart Function
    
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
    
    
    // MARK: - Chart Button Functions
    
    @IBAction func displayXAcc(_ sender: Any) {
        var line = [BarChartDataEntry]()
        let axis = appDelegate.accX_graph[contactIndex]
        for x in 0...119 {
            line.append(BarChartDataEntry(x: Double(x)/80.0, y: axis[x]))
        }
        updateLineChart(line_entries: line, name: "X Acceleration")
    }
    @IBAction func displayYAcc(_ sender: Any) {
        var line = [BarChartDataEntry]()
        let axis = appDelegate.accY_graph[contactIndex]
        for x in 0...119 {
            line.append(BarChartDataEntry(x: Double(x)/80.0, y: axis[x]))
        }
        updateLineChart(line_entries: line, name: "Y Acceleration")
    }
    @IBAction func displayZAcc(_ sender: Any) {
        var line = [BarChartDataEntry]()
        let axis = appDelegate.accZ_graph[contactIndex]
        for x in 0...119 {
            line.append(BarChartDataEntry(x: Double(x)/80.0, y: axis[x]))
        }
        updateLineChart(line_entries: line, name: "Z Acceleration")
    }
    @IBAction func displayXGyro(_ sender: Any) {
        var line = [BarChartDataEntry]()
        let axis = appDelegate.rotX_graph[contactIndex]
        for x in 0...119 {
            line.append(BarChartDataEntry(x: Double(x)/80.0, y: axis[x]))
        }
        updateLineChart(line_entries: line, name: "X Rotation")
    }
    @IBAction func displayYGyro(_ sender: Any) {
        var line = [BarChartDataEntry]()
        let axis = appDelegate.rotY_graph[contactIndex]
        for x in 0...119 {
            line.append(BarChartDataEntry(x: Double(x)/80.0, y: axis[x]))
        }
        updateLineChart(line_entries: line, name: "Y Rotation")
    }
    @IBAction func displayZGyro(_ sender: Any) {
        var line = [BarChartDataEntry]()
        let axis = appDelegate.rotZ_graph[contactIndex]
        for x in 0...119 {
            line.append(BarChartDataEntry(x: Double(x)/80.0, y: axis[x]))
        }
        updateLineChart(line_entries: line, name: "Z Rotation")
    }
    
    
    
    // MARK: - Class Button Functions
    
    @IBAction func cutPressed(_ sender: Any) {
        
        if appDelegate.shots[contactIndex] == "Cut" {     // you should probably force everything to lowercase, to avoid wrong test
            accuracy.text = "Classification: Correct"
            appDelegate.percentaccuracy += 1
            print("Real Shot Indicated: \(appDelegate.percentaccuracy)")
        }
        else {accuracy.text = "Classification: Incorrect"}
    }
    
    @IBAction func defensivePressed(_ sender: Any) {
        
        if appDelegate.shots[contactIndex] == "Defensive" {     // you should probably force everything to lowercase, to avoid wrong test
            accuracy.text = "Classification: Correct"
            appDelegate.percentaccuracy += 1
            print("Real Shot Indicated: \(appDelegate.percentaccuracy)")
        }
        else {accuracy.text = "Classification: Incorrect"}
    }
    
    @IBAction func drivePressed(_ sender: Any) {
        
        if appDelegate.shots[contactIndex] == "Drive" {     // you should probably force everything to lowercase, to avoid wrong test
            accuracy.text = "Classification: Correct"
            appDelegate.percentaccuracy += 1
        }
        else {accuracy.text = "Classification: Incorrect"}
    }
    
    @IBAction func pullPressed(_ sender: Any) {
        
        if appDelegate.shots[contactIndex] == "Pull" {     // you should probably force everything to lowercase, to avoid wrong test
            accuracy.text = "Classification: Correct"
            appDelegate.percentaccuracy += 1
        }
        else {accuracy.text = "Classification: Incorrect"}
    }
    
    @IBAction func sweepPressed(_ sender: Any) {
        
        if appDelegate.shots[contactIndex] == "Sweep" {     // you should probably force everything to lowercase, to avoid wrong test
            accuracy.text = "Classification: Correct"
            appDelegate.percentaccuracy += 1
        }
        else {accuracy.text = "Classification: Incorrect"}
    }
    
    @IBAction func otherPressed(_ sender: Any) {
        
        accuracy.text = "Classification: Incorrect"
    }
    
}
