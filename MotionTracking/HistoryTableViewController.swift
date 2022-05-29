//
//  HistoryTableViewController.swift
//  SwingWatch
//
//  Created by Dan Anderton on 29/05/2022.
//  Copyright © 2022 Apple Inc. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var sessionSelected = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return appDelegate.session_no
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Session History", for: indexPath)
        let tablecounter = Array(stride(from: 1, through: appDelegate.session_no, by: 1))
        
        cell.textLabel?.text = "Session \(tablecounter[indexPath.row])"

        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sessionSelected = indexPath.row
        performSegue(withIdentifier: "Show History", sender: nil)
    }
    
 
    


    // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         if (segue.identifier == "Show History") {
             let historyViewController: HistoryViewController = segue.destination as! HistoryViewController
             historyViewController.sessionIndex = sessionSelected
         }
     }

}
