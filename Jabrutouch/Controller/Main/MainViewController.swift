//בעזת ה׳ החונן לאדם דעת
//  MainViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 18/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

enum MainModal {
    case downloads
    case gemara
    case mishna
    case donations
    
}

protocol MainModalDelegate {
    func dismissMainModal()
}

class MainViewController: UIViewController, MainModalDelegate {

    //========================================
    // MARK: - Properties
    //========================================
    private var modalsPresentingVC: UIViewController!
    private var currentPresentedModal: MainModal?
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    @IBOutlet weak private var mainContainer: UIView!
    @IBOutlet weak private var modalsContainer: UIView!
    
    // Tab bar buttons
    @IBOutlet weak private var downloadsImageView: UIImageView!
    @IBOutlet weak private var downloadsLabel: UILabel!
    @IBOutlet weak private var downloadsButton: UIButton!
    
    @IBOutlet weak private var gemaraImageView: UIImageView!
    @IBOutlet weak private var gemaraLabel: UILabel!
    @IBOutlet weak private var gemaraButton: UIButton!
    
    @IBOutlet weak private var mishnaImageView: UIImageView!
    @IBOutlet weak private var mishnaLabel: UILabel!
    @IBOutlet weak private var mishnaButton: UIButton!
    
    @IBOutlet weak private var donationsImageView: UIImageView!
    @IBOutlet weak private var donationsLabel: UILabel!
    @IBOutlet weak private var donationsButton: UIButton!
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func downloadsButtonTouchedDown(_ sender: UIButton) {
        self.downloadsImageView.alpha = 0.3
        self.downloadsLabel.alpha = 0.3
    }
    
    @IBAction func downloadsButtonTouchedUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.downloadsImageView.alpha = 1.0
            self.downloadsLabel.alpha = 1.0
        }
        self.presentDownloadsViewController()
    }
    
    @IBAction func downloadsButtonTouchedUpOutside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.downloadsImageView.alpha = 1.0
            self.downloadsLabel.alpha = 1.0
        }
    }
    
    @IBAction func gemaraButtonTouchedDown(_ sender: UIButton) {
        self.gemaraImageView.alpha = 0.3
        self.gemaraLabel.alpha = 0.3
    }
    
    @IBAction func gemaraButtonTouchedUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.gemaraImageView.alpha = 1.0
            self.gemaraLabel.alpha = 1.0
        }
        self.presentGemaraViewController()
    }
    
    @IBAction func gemaraButtonTouchedUpOutside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.gemaraImageView.alpha = 1.0
            self.gemaraLabel.alpha = 1.0
        }
    }
    
    @IBAction func mishnaButtonTouchedDown(_ sender: UIButton) {
        self.mishnaImageView.alpha = 0.3
        self.mishnaLabel.alpha = 0.3
    }
    
    @IBAction func mishnaButtonTouchedUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.mishnaImageView.alpha = 1.0
            self.mishnaLabel.alpha = 1.0
        }
        self.presentMishnaViewController()
    }
    
    @IBAction func mishnaButtonTouchedUpOutside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.mishnaImageView.alpha = 1.0
            self.mishnaLabel.alpha = 1.0
        }
    }
    
    @IBAction func donationsButtonTouchedDown(_ sender: UIButton) {
        self.donationsImageView.alpha = 0.3
        self.donationsLabel.alpha = 0.3
    }
    
    @IBAction func donationsButtonTouchedUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.donationsImageView.alpha = 1.0
            self.donationsLabel.alpha = 1.0
        }
        self.presentDonationsViewController()
    }
    
    @IBAction func donationsButtonTouchedUpOutside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.donationsImageView.alpha = 1.0
            self.donationsLabel.alpha = 1.0
        }
    }
    
    //========================================
    // MARK: - Navigation
    //========================================
    
    private func presentDownloadsViewController() {
        if self.currentPresentedModal != nil && self.currentPresentedModal != .downloads {
            self.modalsPresentingVC.dismiss(animated: true) {
                self.modalsPresentingVC.performSegue(withIdentifier: "presentDownloads", sender: nil)
            }
        }
        else if self.currentPresentedModal == nil{
            self.view.bringSubviewToFront(self.modalsContainer)
            self.modalsPresentingVC.performSegue(withIdentifier: "presentDownloads", sender: nil)
        }
        self.currentPresentedModal = .downloads
    }
    
    private func presentGemaraViewController() {
        if self.currentPresentedModal != nil && self.currentPresentedModal != .gemara {
            self.modalsPresentingVC.dismiss(animated: true) {
                self.modalsPresentingVC.performSegue(withIdentifier: "presentGemara", sender: nil)
            }
        }
        else if self.currentPresentedModal == nil{
            self.view.bringSubviewToFront(self.modalsContainer)
            self.modalsPresentingVC.performSegue(withIdentifier: "presentGemara", sender: nil)
        }
        self.currentPresentedModal = .gemara
    }
    
    private func presentMishnaViewController() {
        if self.currentPresentedModal != nil && self.currentPresentedModal != .mishna {
            self.modalsPresentingVC.dismiss(animated: true) {
                self.modalsPresentingVC.performSegue(withIdentifier: "presentMishna", sender: nil)
            }
        }
        else if self.currentPresentedModal == nil{
            self.view.bringSubviewToFront(self.modalsContainer)
            self.modalsPresentingVC.performSegue(withIdentifier: "presentMishna", sender: nil)
        }
        self.currentPresentedModal = .mishna
    }
    
    private func presentDonationsViewController() {
        if self.currentPresentedModal != nil && self.currentPresentedModal != .donations {
            self.modalsPresentingVC.dismiss(animated: true) {
                self.modalsPresentingVC.performSegue(withIdentifier: "presentDonations", sender: nil)
            }
        }
        else if self.currentPresentedModal == nil{
            self.view.bringSubviewToFront(self.modalsContainer)
            self.modalsPresentingVC.performSegue(withIdentifier: "presentDonations", sender: nil)
        }
        self.currentPresentedModal = .donations
    }
    
    func dismissMainModal() {
        self.modalsPresentingVC.dismiss(animated: true) {
            self.view.bringSubviewToFront(self.mainContainer)
            self.currentPresentedModal = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedModalsVC" {
            self.modalsPresentingVC = segue.destination
        }
    }
}
