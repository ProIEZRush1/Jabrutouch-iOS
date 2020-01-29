//בעזרת ה׳ החונן לאדם דעת
//  DonationsViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 18/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class DonationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: MainModalDelegate?
    
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    //Header View
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerShadowBasis: UIView!
    @IBOutlet weak var recentButton: UIButton!
    @IBOutlet weak var donorsButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var grayUpArrow: UIImageView!
    @IBOutlet weak var initialGrayUpArrowXCentererdToRecent: NSLayoutConstraint!
    
    //no recent view
    @IBOutlet weak var donationsImage: UIImageView!
    @IBOutlet weak var noDonationsTitelMessage: UILabel!
    
    // donate view
    @IBOutlet weak var donationMessage: UILabel!
    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var containerViewTralingConsraint: NSLayoutConstraint!
    
    @IBOutlet weak var donorsTableView: UITableView!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var donorsTableViewLeadingConsraint: NSLayoutConstraint!
    
    //====================================================
    // MARK: - Properties
    //====================================================
    
    fileprivate var grayUpArrowXCentererdToRecent: NSLayoutConstraint?
    fileprivate var grayUpArrowXCentererdToDonors: NSLayoutConstraint?
    fileprivate var grayUpArrowXCentererdToHistory: NSLayoutConstraint?
    fileprivate var isRecentSelected = true
    fileprivate var isDonorSelected = false
    fileprivate var isHistorySelected = false
    fileprivate var tableViewsMap = [String: UITableView]()
    fileprivate let DONORS = "Donors"
    fileprivate let HISTORY = "History"
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialGrayUpArrowXCentererdToRecent.isActive = false
        
        self.setViewsShadow()
        self.setTableViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setSelectedPage()
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    func setTableViews(){
        self.donorsTableView.delegate = self
        self.donorsTableView.dataSource = self
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self

        self.tableViewsMap[DONORS] = donorsTableView
        self.tableViewsMap[HISTORY] = historyTableView
    }
    
    fileprivate func setButtonsColorAndFont() {
        recentButton.backgroundColor = isRecentSelected ? .white : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        donorsButton.backgroundColor = isDonorSelected ? .white : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        historyButton.backgroundColor = isHistorySelected ? .white : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        
        recentButton.titleLabel?.font = isRecentSelected ? UIFont(name: "SFProDisplay-Heavy", size: 18) : UIFont(name: "SFProDisplay-Medium", size: 18)
        donorsButton.titleLabel?.font = isDonorSelected ? UIFont(name: "SFProDisplay-Heavy", size: 18) : UIFont(name: "SFProDisplay-Medium", size: 18)
        historyButton.titleLabel?.font = isHistorySelected ? UIFont(name: "SFProDisplay-Heavy", size: 18) : UIFont(name: "SFProDisplay-Medium", size: 18)
        
        recentButton.setTitleColor(isRecentSelected ? UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 1) : UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 0.55), for: .normal)
        donorsButton.setTitleColor(isDonorSelected ? UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 1) : UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 0.55), for: .normal)
        historyButton.setTitleColor(isHistorySelected ? UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 1) : UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 0.55), for: .normal)
    }
    
    fileprivate func setSelectedPage() {
        setButtonsColorAndFont()
        setGrayUpArrowPosition()
//        checkIfTableViewEmpty(gemaraDownloads, gemaraTableView)
//        checkIfTableViewEmpty(mishnaDownloads, mishnaTableView)
    }
    
    fileprivate func setGrayUpArrowPosition() {
        if isRecentSelected {
            grayUpArrowXCentererdToRecent?.isActive = true
            grayUpArrowXCentererdToDonors?.isActive = false
            grayUpArrowXCentererdToHistory?.isActive = false
        } else if isDonorSelected {
            grayUpArrowXCentererdToDonors?.isActive = true
            grayUpArrowXCentererdToRecent?.isActive = false
            grayUpArrowXCentererdToHistory?.isActive = false
        } else {
            grayUpArrowXCentererdToHistory?.isActive = true
            grayUpArrowXCentererdToDonors?.isActive = false
            grayUpArrowXCentererdToRecent?.isActive = false
        }
        
        grayUpArrow.layoutIfNeeded()
    }
    
    
    fileprivate func setViewsShadow() {
        let borderColor = UIColor(red: 0.93, green: 0.94, blue: 0.96, alpha: 1)
        let headerShadowColor = UIColor(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.07)
        let shadowOffset = CGSize(width: 0.0, height: 10)
        let headerShadowOffset = CGSize(width: 0, height: 4)
        let cornerRadius = recentButton.layer.frame.height / 2
        
        Utils.setViewShape(view: recentButton, viewBorderWidht: 0, viewBorderColor: borderColor, viewCornerRadius: cornerRadius)
        Utils.dropViewShadow(view: recentButton, shadowColor: Colors.shadowColor, shadowRadius: 20, shadowOffset: shadowOffset)
        
        Utils.setViewShape(view: donorsButton, viewBorderWidht: 0, viewBorderColor: borderColor, viewCornerRadius: cornerRadius)
        Utils.dropViewShadow(view: donorsButton, shadowColor: Colors.shadowColor, shadowRadius: 20, shadowOffset: shadowOffset)
        
        Utils.setViewShape(view: historyButton, viewBorderWidht: 0, viewBorderColor: borderColor, viewCornerRadius: cornerRadius)
        Utils.dropViewShadow(view: historyButton, shadowColor: Colors.shadowColor, shadowRadius: 20, shadowOffset: shadowOffset)
        
        Utils.dropViewShadow(view: headerShadowBasis, shadowColor: headerShadowColor, shadowRadius: 22, shadowOffset: headerShadowOffset)
        
        self.donateButton.layer.cornerRadius = 18
        
        grayUpArrowXCentererdToRecent = grayUpArrow.centerXAnchor.constraint(equalTo: recentButton.centerXAnchor)
        grayUpArrowXCentererdToDonors = grayUpArrow.centerXAnchor.constraint(equalTo: donorsButton.centerXAnchor)
        grayUpArrowXCentererdToHistory = grayUpArrow.centerXAnchor.constraint(equalTo: historyButton.centerXAnchor)
    }
    
    fileprivate func switchViews() {
        setGrayUpArrowPosition()
        setSelectedPage()
        UIView.animate(withDuration: 0.3) {
            if self.isDonorSelected {
                self.donorsTableViewLeadingConsraint.constant = -self.view.frame.width
                self.containerViewTralingConsraint.constant = self.view.frame.width
            } else if self.isHistorySelected {
                self.containerViewTralingConsraint.constant = self.view.frame.width
                self.donorsTableViewLeadingConsraint.constant = -self.view.frame.width * 2
            } else {
                self.containerViewTralingConsraint.constant = 0
                self.donorsTableViewLeadingConsraint.constant = 0
                
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func getTime(_ historyTime: Date)-> String{
        let dateFormatter = DateFormatter()
        var date: String
        
        dateFormatter.dateFormat = "dd-M-yyyy"
        date = dateFormatter.string(from: historyTime)
        
        return date
    }
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.delegate?.dismissMainModal()
    }
    
    @IBAction func recentButtonPressed(_ sender: Any) {
        self.isRecentSelected = true
        self.isDonorSelected = false
        self.isHistorySelected = false
        self.switchViews()
    }
    
    @IBAction func donorsButtonPressed(_ sender: Any) {
        self.isDonorSelected = true
        self.isRecentSelected = false
        self.isHistorySelected = false
       self.switchViews()
    }
    
    @IBAction func historyButtonPressed(_ sender: Any) {
        self.isHistorySelected = true
        self.isRecentSelected = false
        self.isDonorSelected = false
        self.switchViews()
    }
    
    @IBAction func donateButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "presentDonation", sender: self)
    }
    
    //========================================
    // MARK: - UITabelView
    //========================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == donorsTableView {
            return 5
        } else {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == donorsTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "donorCell", for: indexPath) as! DonorsCell
            cell.fullNameLabel.text = "Shlomo Carmen"
            cell.numberLabel.text = "\(5 * indexPath.row + 1)"
            return cell
        }
        else if tableView == historyTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
            cell.dateLabel.text = self.getTime(Date())
            cell.amountLabel.text = "$\(7 * indexPath.row + 1)"
            cell.numberLabel.text = "\(10 * indexPath.row)"
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    
    
}
