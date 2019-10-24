//
//  EditProfileViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backPressed(_ sender: Any) {
           dismiss(animated: true, completion: nil)
       }
       
    @IBAction func doneButtonPressed(_ sender: Any) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "completionProgress") as? CompletionProgressCell else { return UITableViewCell() }
            let count = 60.0
            let progress = CGFloat(count/100)
            cell.completionPercentage.text = "\(Int(count))% Full"
            cell.progressView.progress = progress
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InterestsCell") as? InterestsCell else { return UITableViewCell() }
            
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    


}
