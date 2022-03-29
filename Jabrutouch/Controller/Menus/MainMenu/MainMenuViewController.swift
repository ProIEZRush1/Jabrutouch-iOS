//בעזרת ה׳ החונן לאדם דעת
//  MainMenuViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 23/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

protocol MenuDelegate: class {
    func optionSelected(option: MenuOption)
}

enum MenuOption {
    case profile
    case about
    case messageCenter
    case mishna
    case gemara
    case donationsCenter
    case donate
    case newsFeed
    case signOut
}

class MainMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //===============================================
    // MARK: - @IBOutlet section
    //===============================================
    
    @IBOutlet weak var containerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    
    //===============================================
    // MARK: - Properties
    //===============================================
    
    
    weak var delegate: MenuDelegate?
    let animationTime:Double = 0.3
    var preferencesCellCollapsed = true
    var walletCellCollapsed = true
    
    //===============================================
    // MARK: - Life Cycle section
    //===============================================
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return [.portrait, .landscapeLeft, .landscapeRight]
        } else {
            return [.portrait]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide menu before presentation
        self.containerViewLeadingConstraint.constant = -(self.view.frame.width * 29/32)
        self.view.layoutIfNeeded()
        self.backgroundButton.alpha = 0.0
        
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.tableView.bounds.width, height: 40.0))
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        // Animate menu in
        UIView.setAnimationCurve(.easeIn)
        UIView.animate(withDuration: self.animationTime) {
            self.containerViewLeadingConstraint.constant = 0.0
            self.view.layoutIfNeeded()
            self.backgroundButton.alpha = 1.0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //===============================================
    // MARK - Setup methods
    //===============================================
    
    private func setKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification,object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification,object:nil)
        UIView.setAnimationCurve(UIView.AnimationCurve.easeIn)
    }
    
    //===============================================
    // MARK: - Keyboard observer section
    //===============================================
    
    @objc func keyboardWillShow(_ sender:Notification){
        
        let keyboardHeight = (((sender as NSNotification).userInfo![UIResponder.keyboardFrameEndUserInfoKey]) as! NSValue).cgRectValue.size.height
        let duration = (((sender as NSNotification).userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]) as! NSNumber) as! Double
        
        animateView(duration,target: keyboardHeight)
        
    }
    
    @objc func keyboardWillHide(_ sender:Notification){
        let duration = (((sender as NSNotification).userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]) as! NSNumber) as! Double
        animateView(duration,target: 0)
    }
    
    func animateView(_ duration:Double, target:CGFloat){
        UIView.animate(withDuration: duration, animations: {
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
        })
    }
    
    
    //===============================================
    // MARK: - @IBAction section
    //===============================================
    
    @IBAction func containerViewPanned(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self.containerView)
        
        switch sender.state {
        case .began:
            self.pannigBegan(at: point)
        case .changed:
            self.pannigMoved(to: point)
        case .ended:
            self.pannigEnded(at: point)
        case .cancelled,.failed:
            self.pannigCanceled(at: point)
        default:
            break
        }
    }
    
    @IBAction func backgroundButtonPressed(_ sender:UIButton){
        self.dismissMenu(completion: nil)
    }
    
    //===============================================
    // MARK: - Panning methods Section
    //===============================================
    
    private var lastPannedPoint:CGPoint?
    func pannigBegan(at point:CGPoint){
        self.lastPannedPoint = point
    }
    private func pannigMoved(to point:CGPoint){
        guard let lastPoint = self.lastPannedPoint else { return }
        let diffX = point.x - lastPoint.x
        self.containerViewLeadingConstraint.constant = min(self.containerViewLeadingConstraint.constant + diffX,0)
        let percentage = 1.0 + self.containerViewLeadingConstraint.constant/self.containerView.bounds.width
        self.backgroundButton.alpha = percentage
        self.view.layoutIfNeeded()
    }
    private func pannigEnded(at point:CGPoint){
        self.lastPannedPoint = nil
        let percentage = Double(1.0 + self.containerViewLeadingConstraint.constant/self.containerView.bounds.width)
        if percentage >= 0.7 {
            // Extend menu
            let time = self.animationTime * (1.0 - percentage)
            UIView.animate(withDuration: time) {
                self.containerViewLeadingConstraint.constant = 0.0
                self.view.layoutIfNeeded()
                self.backgroundButton.alpha = 1.0
            }
        }
        else {
            // Hide remaining menu
            let time = self.animationTime * percentage
            UIView.animate(withDuration: time, animations: {
                self.containerViewLeadingConstraint.constant = -self.containerView.bounds.width
                self.view.layoutIfNeeded()
                self.backgroundButton.alpha = 0.0
            }) { (Bool) in
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    private func pannigCanceled(at point:CGPoint){
        self.lastPannedPoint = nil
    }
    
    //===============================================
    // MARK: - TableView section
    //===============================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as? MenuTableViewCell else { return UITableViewCell() }
        switch indexPath.row {
        case 0:
            cell.label?.text = Strings.profile
        case 1:
            cell.label?.text = Strings.about
        case 2:
            cell.label?.text = Strings.messagesCenter
        case 3:
            cell.label?.text = Strings.mishna
        case 4:
            cell.label?.text = Strings.gemara
        case 5:
            cell.label?.text = Strings.donationsCenter
//        case 6:
//            cell.label?.text = Strings.donate
        case 6:
            cell.label?.text = Strings.newsFeed
        case 7:
            cell.label?.text = Strings.signOut
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.dismissMenu {
                self.delegate?.optionSelected(option: .profile)
            }
        case 1:
            self.dismissMenu {
                self.delegate?.optionSelected(option: .about)
            }
        case 2:
            self.dismissMenu {
                self.delegate?.optionSelected(option: .messageCenter)
            }
        case 3:
            self.dismissMenu {
                self.delegate?.optionSelected(option: .mishna)
            }
        case 4:
            self.dismissMenu {
                self.delegate?.optionSelected(option: .gemara)
            }
        case 5:
            self.dismissMenu {
                self.delegate?.optionSelected(option: .donationsCenter)
            }
//        case 6:
//            self.dismissMenu {
//                self.delegate?.optionSelected(option: .donate)
//            }
        case 6:
            self.dismissMenu {
                self.delegate?.optionSelected(option: .newsFeed)
            }
        case 7:
            self.dismissMenu {
                self.delegate?.optionSelected(option: .signOut)
            }
        
        default:
            break
        }
    }
    
    
    //===============================================
    // MARK: - Navigation
    //===============================================
    
    func dismissMenu(completion:(()->Void)?){
        UIView.animate(withDuration: self.animationTime, animations: {
            self.containerViewLeadingConstraint.constant = -self.containerView.bounds.width
            self.view.layoutIfNeeded()
            self.backgroundButton.alpha = 0.0
        }) { (Bool) in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}
