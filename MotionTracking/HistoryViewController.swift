//
//  HistoryViewController.swift
//  SwingWatch
//
//  Created by Dan Anderton on 29/05/2022.
//  Copyright © 2022 Apple Inc. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    
    var sessionIndex = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    @IBOutlet weak var session: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var durationend: UILabel!
    @IBOutlet weak var chart: UIImageView!
    
    
    @IBOutlet weak var shot: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tablecounter = Array(stride(from: 1, through: appDelegate.session_no, by: 1))
        
        session.text = "Session \(tablecounter[sessionIndex])"
        duration.text = "\(appDelegate.starttimes[sessionIndex])"
        durationend.text = "\(appDelegate.endtimes[sessionIndex])"
        
        chart.image = appDelegate.image[sessionIndex].toImage() // it will convert String  to UIImage
        

    }
    
    
    func setImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }

            // just not to cause a deadlock in UI!
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }

            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.chart.image = image
            }
        }
    }

}


extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}
