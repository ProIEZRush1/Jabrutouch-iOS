//
//  EditProfileViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    var user: JTUser?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        user = UserDefaultsProvider.shared.currentUser
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backPressed(_ sender: Any) {
           dismiss(animated: true, completion: nil)
       }
       
    @IBAction func doneButtonPressed(_ sender: Any) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 9
        case 3:
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editPersonalDetails") as? EditPersonalDetailsCell else { return UITableViewCell() }
            cell.firstNameTextField.text = user?.firstName
            cell.lastNameTextField.text = user?.lastName
            cell.profileImage.image = #imageLiteral(resourceName: "Avatar")
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "editGeneralInformation") as? EditGeneralInformationCell else { return UITableViewCell() }
            
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = user?.email
                cell.titleLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                cell.arrowImage.isHidden = true
            case 1:
                cell.titleLabel.text = "Country"
                cell.titleLabel.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.88)
                cell.arrowImage.isHidden = false
            case 2:
                cell.titleLabel.text = user?.phoneNumber
                cell.titleLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                cell.arrowImage.isHidden = true
            case 3:
                cell.titleLabel.text = "Birthday"
                cell.titleLabel.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.88)
                cell.arrowImage.isHidden = true
            case 4:
                cell.titleLabel.text = "Community"
                cell.titleLabel.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.88)
                cell.arrowImage.isHidden = false
            case 5:
                cell.titleLabel.text = "Religious Level"
                cell.titleLabel.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.88)
                cell.arrowImage.isHidden = false
            case 6:
                cell.titleLabel.text = "Education"
                cell.titleLabel.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.88)
                cell.arrowImage.isHidden = false
            case 7:
                cell.titleLabel.text = "Occupation"
                cell.titleLabel.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.88)
                cell.arrowImage.isHidden = false
            case 8:
                cell.titleLabel.text = "Second Email Address"
                cell.titleLabel.textColor = #colorLiteral(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.88)
                cell.arrowImage.isHidden = true
            default:
                break
            }
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InterestsCell") as? InterestsCell else { return UITableViewCell() }
            
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 60
        case 1:
            return 105
        case 2:
            return 60
        case 3:
            return 200
        default:
            return 60
        }
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            switch indexPath.section {
            case 0, 1, 3:
                break
            case 2:
                switch indexPath.row {
                case 0, 2:
                    break
                case 1:
                    print("change password selected")
                case 4:
                    print("remove account selected")
                case 5:
                    print("remove account selected")
                case 6:
                    print("remove account selected")
                case 7:
                    print("remove account selected")
                default:
                    break
                }
            default:
                break
            }
        }

}
