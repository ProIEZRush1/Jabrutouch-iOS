//
//  DedicationViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 29/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class DedicationViewController: UIViewController, iCarouselDataSource, iCarouselDelegate, UITextFieldDelegate{
   //========================================
    // MARK: - Properties
    //========================================
   
    var views: [DedicationCardView] = []
    var user: JTUser?
    var anonimus: Bool = false
    var name: String = ""
    var amountToPay: Int = 0
    var isSubscription: Bool = false
    var dedication: [JTDedication] = []
    
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var barPageIndicator: JTBarPageIndicator!
    @IBOutlet weak var continuButton: UIButton!
    @IBOutlet weak var carouselTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var anonimusView: UIView!
    @IBOutlet weak var anonimusButton: UIButton!
    @IBOutlet weak var anonimusLabel: UILabel!

    @IBOutlet weak var carouselView: iCarousel!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var rightArrowButton: UIButton!
    
    //========================================
    // MARK: - LifeCycle
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCarousel()
        self.setRoundCorners()
        self.leftArrowButton.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.user = UserRepository.shared.getCurrentUser()
        
        self.setCurrentCards()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.carouselView.reloadData()
        self.view.layoutIfNeeded()
    }
    
    func setCarousel() {
        self.carouselView.delegate = self
        self.carouselView.dataSource = self
        self.carouselView.type = .custom
        self.carouselView.isPagingEnabled = true
        self.carouselView.reloadData()
    }
    
    private func setRoundCorners() {
        self.continuButton.layer.cornerRadius = 18
        self.continuButton.clipsToBounds = true
        
    }
    
    func setCardView(dedication: String, hidden: Bool) {
        let view = DedicationCardView()
        view.textField.delegate = self
        view.editNameTextField.delegate = self
        view.delegate = self
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        view.profileImage.image = user?.profileImage ?? #imageLiteral(resourceName: "Avatar")
        view.userNameLabel.text = "\(user?.firstName ?? "") \(user?.lastName ?? "")"
        view.countryLabel.text = user?.country ?? ""
        view.dedicationLabel.text = dedication
        view.dedicationLabel.isHidden = hidden
        view.textFieldView.isHidden = hidden
        view.setBorders()
        view.roundCornors()
        view.setShadow()
        
        if hidden {
            view.topLabelConstraint.constant = 50
        }
        self.views.append(view)
    }
    
    func setCurrentCards() {
        self.setCardView(dedication: "", hidden: true)
        for dedication in self.dedication {
            self.setCardView(dedication: dedication.name, hidden: false)
        }
    }
    
    //========================================
    // MARK: - @IBAction
    //========================================
    
    @IBAction func backButtonBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func anonimusButtonPreesed(_ sender: Any) {
        self.anonimus.toggle()
        if anonimus {
            self.anonimusButton.setImage(#imageLiteral(resourceName: "circelV"), for: .normal)
            self.anonimusLabel.alpha = 1
            self.anonimusLabel.textColor = Colors.appOrange
            for card in self.views {
                card.userNameLabel.text = "N N"
            }
        } else {
            self.anonimusButton.setImage(#imageLiteral(resourceName: "anonimus"), for: .normal)
            self.anonimusLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.43)
            self.anonimusLabel.alpha = 0.43
            for card in self.views {
                card.userNameLabel.text = "\(user?.firstName ?? "") \(user?.lastName ?? "")"
            }
        }
        
        self.carouselView.reloadData()
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        let index = self.barPageIndicator.selectedIndex
        let card = self.views[index]
        if let name = card.textField.text {
            self.name = name
        }
        self.performSegue(withIdentifier: "presentPayment", sender: self)
    }
    
    //========================================
    // MARK: - iCarousel
    //========================================
    
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return self.views.count
    }
    
    func carouselItemWidth(_ carousel: iCarousel) -> CGFloat {
        return carousel.bounds.width * 0.75
    }
    
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {

        let width = carousel.itemWidth
        let height = carousel.bounds.height
        let frame = CGRect(x: 0, y: 0, width: width, height: height)

        let view = self.views[index]
        view.frame = frame
        
        return view
        
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        var value = value
        if option == .wrap {
            value = 0.0
        }
        if option == .spacing {
            value = value * 1.15
        }
        
        return value
    }
    
    func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        let distance: CGFloat = 50.0
        //number of pixels to move the items away from camera
        let spacing: CGFloat = 0.15
        //extra spacing for center item
        let clampedOffset: CGFloat = min(1.0, max(-1.0, offset))
        let z: CGFloat = -abs(clampedOffset) * distance
        var offset = offset
        offset += clampedOffset * spacing
        return CATransform3DTranslate(transform, offset * carousel.itemWidth, 0.0, z)

    }
    
    func carouselDidScroll(_ carousel: iCarousel) {
        
        self.barPageIndicator.selectedIndex = carousel.currentItemIndex
        
        if carousel.currentItemIndex > 0 {
            self.leftArrowButton.isHidden = false
        } else {
            self.leftArrowButton.isHidden = true
        }
        if carousel.currentItemIndex < 3 {
            self.rightArrowButton.isHidden = false
        } else {
            self.rightArrowButton.isHidden = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.carouselTopConstraint.constant = -90
            self.view.layoutIfNeeded()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.carouselTopConstraint.constant = 20
            self.view.layoutIfNeeded()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.carouselTopConstraint.constant = 20
            self.view.layoutIfNeeded()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentPayment" {
            let paymentVC = segue.destination as? PaymentViewController
            paymentVC?.amountToPay = self.amountToPay
            paymentVC?.isSubscription = self.isSubscription
        }
    }
}

extension DedicationViewController: DedicationCardDelegate {
    func changedName(_ name: String) {
        if name != "" {
            for card in self.views {
                card.userNameLabel.text = name
            }
        }
        self.carouselView.reloadData()
    }
    
}
