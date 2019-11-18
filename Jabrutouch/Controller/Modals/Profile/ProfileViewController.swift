//בס״ד
//  ProfileViewController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 07/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlertViewDelegate {
    
  
    //========================================
    // MARK: - Properties
    //========================================
    
    var user: JTUser?
    var mainViewController: MainViewController?
    //========================================
    // MARK: - @IBOutlets
    //========================================
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!

    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = UserDefaultsProvider.shared.currentUser
        self.setStrings()
        self.roundCorners()
        self.setShadows()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    private func setStrings() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        self.versionLabel.text = "Version \(version) (\(build))"

    }
    
    private func roundCorners() {
        self.tableView.layer.cornerRadius = 15
//        self.logoutBtn.layer.cornerRadius = 10
    }
    
    private func setShadows() {
//        let shadowOffset = CGSize(width: 0.0, height: 12)
//        Utils.dropViewShadow(view: self.mainContentView, shadowColor: Colors.shadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
    }
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toEditProfile", sender: self)
    }
    
    //========================================
    // MARK: - UITableView
    //========================================
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 7
        case 4:
            return 1
        case 5:
            return 3
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PesonalDetailsCell") as? PersonalDetailsCell else { return UITableViewCell() }
            cell.nameLabel.text = "\(self.user!.firstName) \(self.user!.lastName)"
            cell.emailLabel.text = self.user!.email
            if self.user!.country != "" {
                cell.country.text = self.user!.country
            } else {
                cell.country.text = LocalizationManager.shared.getDefaultCountry()?.fullDisplayName//"country"
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DonationInformationCell") as? DonationInformationCell else { return UITableViewCell() }
            cell.donatedLabel.text = "20"
            cell.learedLabel.text = "5"
            cell.containerView.clipsToBounds = false
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "completionProgress") as? CompletionProgressCell else { return UITableViewCell() }
            let count = 80.0
            let progress = CGFloat(count/100)
            cell.completionPercentage.text = "\(Int(count))% Full"
            cell.progressView.progress = progress
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralInformationCell") as? GeneralInformationCell else { return UITableViewCell() }
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Phone Number"
                cell.infoLabel.text = self.user!.phoneNumber
            case 1:
                cell.titleLabel.text = "Birthday"
                cell.infoLabel.text = self.user!.birthdayString
            case 2:
                cell.titleLabel.text = "Community"
                cell.infoLabel.text = self.user!.community?.name
            case 3:
                cell.titleLabel.text = "Religious Level"
                cell.infoLabel.text = "\(self.user!.religiousLevel ?? 0) out of 10"
            case 4:
                cell.titleLabel.text = "Education"
                cell.infoLabel.text = self.user!.education ?? ""
            case 5:
                cell.titleLabel.text = "Occupation"
                cell.infoLabel.text = self.user!.occupation ?? ""
            case 6:
                cell.titleLabel.text = "Second Email"
                cell.infoLabel.text = self.user!.secondEmail
            default:
                break
            }
            return cell
            
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InterestsCell") as? InterestsCell else { return UITableViewCell() }
            
            return cell
        case 5:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell") as? ButtonCell else { return UITableViewCell() }
            switch indexPath.row {
            case 0:
                cell.button.setTitle(Strings.logout.uppercased(), for: .normal)
                cell.button.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.168627451, blue: 0.662745098, alpha: 1)
                cell.button.setTitleColor(.white, for: .normal)
            case 1:
                cell.button.setTitle("change password", for: .normal)
                cell.button.setTitleColor(#colorLiteral(red: 0.1764705882, green: 0.168627451, blue: 0.662745098, alpha: 1), for: .normal)
                cell.button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            case 2:
                cell.button.setTitle("remove account", for: .normal)
                cell.button.setTitleColor(#colorLiteral(red: 0.1764705882, green: 0.168627451, blue: 0.662745098, alpha: 1), for: .normal)
                cell.button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            default:
                  break
            }
            return cell
                
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 150
        case 1:
            return 170
        case 2:
            return 100
        case 3:
            return 50
        case 4:
            return 200
        case 5:
            return 56
        default:
            return 150
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0, 1, 2, 3, 4:
            break
        case 5:
            switch indexPath.row {
            case 0:
                self.presentLogoutAlert()
            case 1:
                self.changePassword()
            case 2:
                print("remove account selected")
            default:
                break
            }
        default:
            break
        }
    }
    
    func presentLogoutAlert() {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let myAlert = storyboard.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
           myAlert.delegate = self
           myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
           myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
           self.present(myAlert, animated: true, completion: nil)
       }
    
    func okPressed() {
        LoginManager.shared.signOut {
            DispatchQueue.main.async {
                self.mainViewController?.navigateToSignIn()
            }
        }
    }
    
    func changePassword() {
        performSegue(withIdentifier: "toEditProfile", sender: 4)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditProfile" {
            let editProfileVC = segue.destination as! EditProfileViewController
            if let section = sender as? Int {
                editProfileVC.section = section
            }
        }
    }

    
}
