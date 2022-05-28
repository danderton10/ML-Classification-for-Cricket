//
//  ViewController_Stats.swift
//  SwingWatch
//
//  Created by Dan Anderton on 19/04/2022.
//  Copyright © 2022 Apple Inc. All rights reserved.
//

import UIKit
import WatchConnectivity
import Charts

class ViewController_Stats: UIViewController, ChartViewDelegate {
    
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var barChart: BarChartView!
    
    
    var shots = ["Defensive", "Drive", "Drive", "Cut", "Defensive", "Drive", "Pull", "Pull", "Sweep"]


    override func viewDidLoad() {
        super.viewDidLoad()
        barChart.delegate = self
        pieChart.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var entries = [BarChartDataEntry]()
        
        for x in 0..<10 {
            
            entries.append(BarChartDataEntry(x: Double(x), y: Double(x)))
            
        }
        
        let set = BarChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.pastel()
        let data = BarChartData(dataSet: set)
        barChart.data = data
        
        
        var counts: [String: Int] = [:]
        shots.forEach { counts[$0, default: 0] += 1 }
        
        var names = [String]()
        var values = [Int]()
        
        for (key, value) in counts {
            names.append(key)
            values.append(value)
        }
        
        
        let defensiveDataEntry = PieChartDataEntry(value: 0)
        let driveDataEntry = PieChartDataEntry(value: 0)
        let cutDataEntry = PieChartDataEntry(value: 0)
        let pullDataEntry = PieChartDataEntry(value: 0)
        let sweepDataEntry = PieChartDataEntry(value: 0)
        
        var numberOfDownloadsDataEntries = [PieChartDataEntry]()
            
        pieChart.chartDescription.text = ""
        
        defensiveDataEntry.label = "Defensive"
        let def_index = names.enumerated().filter{ $0.element == "Defensive"}.map{ $0.offset }
        let val_def  = Double(values[def_index[0]])
        defensiveDataEntry.value = val_def
        
        driveDataEntry.label = "Drive"
        let drv_index = names.enumerated().filter{ $0.element == "Drive"}.map{ $0.offset }
        let val_drv  = Double(values[drv_index[0]])
        driveDataEntry.value = val_drv
        
        cutDataEntry.label = "Cut"
        let cut_index = names.enumerated().filter{ $0.element == "Cut"}.map{ $0.offset }
        let val_cut  = Double(values[cut_index[0]])
        cutDataEntry.value = val_cut
        
        pullDataEntry.label = "Pull"
        let pll_index = names.enumerated().filter{ $0.element == "Pull"}.map{ $0.offset }
        let val_pll  = Double(values[pll_index[0]])
        pullDataEntry.value = val_pll
        
        sweepDataEntry.label = "Sweep"
        let swp_index = names.enumerated().filter{ $0.element == "Sweep"}.map{ $0.offset }
        let val_swp  = Double(values[swp_index[0]])
        sweepDataEntry.value = val_swp
        
        numberOfDownloadsDataEntries = [defensiveDataEntry, driveDataEntry, cutDataEntry, pullDataEntry, sweepDataEntry]
        
        
        let chartDataSet = PieChartDataSet(entries: numberOfDownloadsDataEntries)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        chartDataSet.colors = ChartColorTemplates.joyful()
        pieChart.data = chartData
        
        
    }


}
