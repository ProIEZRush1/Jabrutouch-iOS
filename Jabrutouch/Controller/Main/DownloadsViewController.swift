//בעזרת ה׳ החונן לאדם דעת
//  DownloadsViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 18/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class DownloadsViewController: UIViewController {

    @IBOutlet weak var headerShadowBasis: UIView!
    @IBOutlet weak var gemaraButton: UIButton!
    @IBOutlet weak var mishnaButton: UIButton!
    @IBOutlet weak var viewAllButton: UIButton!
    @IBOutlet weak var grayUpArrow: UIImageView!
    @IBOutlet weak var initialGrayUpArrowXCentererdToGemara: NSLayoutConstraint!
    
    weak var delegate: MainModalDelegate?
    
    fileprivate var isGemaraSelected = true
    fileprivate var grayUpArrowXCentererdToGemara: NSLayoutConstraint?
    fileprivate var grayUpArrowXCentererdToMishna: NSLayoutConstraint?
    
    @IBAction func gemaraPressed(_ sender: Any) {
        if !isGemaraSelected {
            switchViews()
        }
    }
    
    fileprivate func switchViews() {
        isGemaraSelected = !isGemaraSelected
        setSelectedPage()
    }
    
    @IBAction func mishnaPressed(_ sender: Any) {
        if isGemaraSelected {
            switchViews()
        }
    }
    
    override func viewDidLoad() {
        initialGrayUpArrowXCentererdToGemara.isActive = false
        grayUpArrowXCentererdToGemara = grayUpArrow.centerXAnchor.constraint(equalTo: gemaraButton.centerXAnchor)
        grayUpArrowXCentererdToMishna = grayUpArrow.centerXAnchor.constraint(equalTo: mishnaButton.centerXAnchor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSelectedPage()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setViews()
    }
    
    fileprivate func setSelectedPage() {
        setButtonsColorAndFont()
        setGrayUpArrowPosition()
    }
    
    fileprivate func setButtonsColorAndFont() {
        gemaraButton.backgroundColor = isGemaraSelected ? .white : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        mishnaButton.backgroundColor = !isGemaraSelected ? .white : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        gemaraButton.titleLabel?.font = isGemaraSelected ? UIFont(name: "SFProDisplay-Heavy", size: 18) : UIFont(name: "SFProDisplay-Medium", size: 18)
        mishnaButton.titleLabel?.font = !isGemaraSelected ? UIFont(name: "SFProDisplay-Heavy", size: 18) : UIFont(name: "SFProDisplay-Medium", size: 18)
        gemaraButton.setTitleColor(isGemaraSelected ? UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 1) : UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 0.55), for: .normal)
        mishnaButton.setTitleColor(!isGemaraSelected ? UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 1) : UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 0.55), for: .normal)
    }
    
    fileprivate func setGrayUpArrowPosition() {
        if isGemaraSelected {
            grayUpArrowXCentererdToMishna?.isActive = false
            grayUpArrowXCentererdToGemara?.isActive = true
        } else {
            grayUpArrowXCentererdToGemara?.isActive = false
            grayUpArrowXCentererdToMishna?.isActive = true
        }
        
        grayUpArrow.layoutIfNeeded()
    }
    
    fileprivate func setViews() {
        setViewsShadow()
        setViewAllButtonShape()
    }
    
    fileprivate func setViewAllButtonShape() {
        viewAllButton.layer.cornerRadius = 10.32
        viewAllButton.layer.borderWidth = 0.57
        viewAllButton.layer.borderColor = UIColor(red: 0.18, green: 0.17, blue: 0.66, alpha: 1).cgColor
        viewAllButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setViewsShadow() {
        let borderColor = UIColor(red: 0.93, green: 0.94, blue: 0.96, alpha: 1)
        let shadowColor = UIColor(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.1)
        let headerShadowColor = UIColor(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.07)
        let shadowOffset = CGSize(width: 0.0, height: 10)
        let headerShadowOffset = CGSize(width: 0, height: 4)
        let cornerRadius = gemaraButton.layer.frame.height / 2
        dropViewShadow(view: gemaraButton, borderWidht: 1, borderColor: borderColor, cornerRadius: cornerRadius, shadowColor: shadowColor, shadowRadius: 20, shadowOffset: shadowOffset)
        dropViewShadow(view: mishnaButton, borderWidht: 1, borderColor: borderColor, cornerRadius: cornerRadius, shadowColor: shadowColor, shadowRadius: 20, shadowOffset: shadowOffset)
        dropViewShadow(view: headerShadowBasis, shadowColor: headerShadowColor, shadowRadius: 22, shadowOffset: headerShadowOffset)
    }
    
    fileprivate func dropViewShadow(view: UIView, borderWidht: CGFloat = 0, borderColor: UIColor = .white, cornerRadius: CGFloat = 0, shadowColor: UIColor, shadowRadius: CGFloat, shadowOffset: CGSize) {
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidht
        view.layer.borderColor = borderColor.cgColor
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = shadowRadius
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.delegate?.dismissMainModal()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
