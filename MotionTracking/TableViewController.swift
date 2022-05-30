//
//  TableViewController.swift
//  SwingWatch
//
//  Created by Dan Anderton on 19/04/2022.
//  Copyright © 2022 Apple Inc. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var shotSelected = 0
    
    @IBOutlet var tableview: UITableView!
    
    var dataSource = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            tableview.reloadData()
        }



    // MARK: - Table view data source

        override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1

    }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return appDelegate.shots.count

    }
    
    
    
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Contact Cell", for: indexPath)
        
        let tablecounter = Array(stride(from: 1, through: appDelegate.shots.count, by: 1))
            cell.textLabel?.text = "Shot \(tablecounter[indexPath.row]): \(appDelegate.shots[indexPath.row])"
//        cell.textLabel?.text = "Shot \(tablecounter[indexPath.row]): \(dataSource[indexPath.row])"
//        tableView.reloadData()
            
//            print("\(dataSource)")

        return cell
    }
    
    
    
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shotSelected = indexPath.row
        performSegue(withIdentifier: "Show Contact", sender: nil)
    }
    
 
    


    // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         if (segue.identifier == "Show Contact") {
             let showContactViewController: TableShowViewController = segue.destination as! TableShowViewController
             showContactViewController.contactIndex = shotSelected
         }
     }


}
