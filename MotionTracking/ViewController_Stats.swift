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

class CellClass: UITableViewCell {
    
}

class ViewController_Stats: UIViewController, ChartViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var btnSelectFruit: UIButton!
    @IBOutlet weak var radarChart: RadarChartView!
    
    @IBOutlet weak var shotlabel: UILabel!
    
    var contactIndex = 0
    let transparentView = UIView()
    let tableView = UITableView()
    var shotSelected = 0
    
    var line_entries = [RadarChartDataEntry]()
    
    var selectedButton = UIButton()
    var dataSource = [String]()
    
//    var firstclick = true
    
    var array = ["Bat Speed","Quality","Bat Angle","Power"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        radarChart.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        
    }
    
    
    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)

        tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 5

        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.dataSource.count * 50))
        }, completion: nil)
    }

    @objc func removeTransparentView() {
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil)
    }

    @IBAction func onClickSelectFruit(_ sender: Any) {
        
        if appDelegate.firstclick == true {
            
            if appDelegate.shots.count > 0 {
            
                for x in 1...appDelegate.shots.count {
                
                    dataSource.append("Shot \(x)")
                }
            }
                else{dataSource.removeAll()}
            
        }
        
        selectedButton = btnSelectFruit
        addTransparentView(frames: btnSelectFruit.frame)
        
        appDelegate.firstclick = false
    }

    

    func updateRadarChart(line_entries: [RadarChartDataEntry], name: String) {
        
        let set = RadarChartDataSet(entries: line_entries)
        let data = RadarChartData(dataSet: set)
        
        
        set.lineWidth = 3

        let redColor = UIColor(red: 247/255, green: 67/255, blue: 115/255, alpha: 1)
        let redFillColor = UIColor(red: 247/255, green: 67/255, blue: 115/255, alpha: 0.6)
        set.colors = [redColor]
        set.fillColor = redFillColor
        set.drawFilledEnabled = true
        set.drawValuesEnabled = false
        set.colors = [NSUIColor(red: CGFloat(0/255), green: CGFloat(255.0/255), blue: CGFloat(255.0/255), alpha: 1)]
        
        
        
        radarChart.webLineWidth = 1.5
        radarChart.innerWebLineWidth = 1.5
        radarChart.webColor = .lightGray
        radarChart.innerWebColor = .lightGray

        let xAxis = radarChart.xAxis
        xAxis.labelFont = .systemFont(ofSize: 9, weight: .bold)
        xAxis.labelTextColor = .black
        xAxis.xOffset = 10
        xAxis.yOffset = 10
        xAxis.drawLabelsEnabled = true
        
        xAxis.gridLineWidth = CGFloat(10.0)
        
        
        xAxis.valueFormatter = IndexAxisValueFormatter(values: array)
        xAxis.labelFont = .systemFont(ofSize: 11, weight: .semibold)

        let yAxis = radarChart.yAxis
        yAxis.labelFont = .systemFont(ofSize: 9, weight: .light)
        yAxis.labelCount = 5
        yAxis.drawTopYLabelEntryEnabled = false
        yAxis.axisMinimum = 0
        
        radarChart.data = data

        radarChart.legend.enabled = false
        
    }




    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedButton.setTitle(dataSource[indexPath.row], for: .normal)
        removeTransparentView()
        
        shotSelected = indexPath.row
        
        var line = [RadarChartDataEntry]()
        let axis = appDelegate.stats[shotSelected]
        print("Performance: \(axis)")
        for x in 0...3 {
            line.append(RadarChartDataEntry(value: axis[x]))
        }
        updateRadarChart(line_entries: line, name: "Shot \(shotSelected+1)")
        
        shotlabel.text = "Shot \(shotSelected+1)"
        
        
        
    }

}
