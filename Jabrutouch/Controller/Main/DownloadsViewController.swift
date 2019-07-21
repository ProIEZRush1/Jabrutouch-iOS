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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
    }
    
    fileprivate func setViews() {
        setHeaderShadow()
        //setButtonsShadow()
        setViewAllButtonShape()
    }
    
    fileprivate func setViewAllButtonShape() {
        viewAllButton.layer.cornerRadius = 10.32
        viewAllButton.layer.borderWidth = 0.57
        viewAllButton.layer.borderColor = UIColor(red: 0.18, green: 0.17, blue: 0.66, alpha: 1).cgColor
        viewAllButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setButtonsShadow() {
        let shadows = UIView()
        shadows.frame = gemaraButton.frame
        shadows.clipsToBounds = false
        gemaraButton.addSubview(shadows)
        
        let shadowPath0 = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: 99)
        
        let layer0 = CALayer()
        layer0.shadowPath = shadowPath0.cgPath
        layer0.shadowColor = UIColor(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.1).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 20
        layer0.shadowOffset = CGSize(width: 0, height: 10)
        layer0.bounds = shadows.bounds
        layer0.position = shadows.center
        shadows.layer.addSublayer(layer0)
        
        let shapes = UIView()
        shapes.frame = gemaraButton.frame
        shapes.clipsToBounds = true
        gemaraButton.addSubview(shapes)
        
        let layer1 = CALayer()
        layer1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        layer1.bounds = shapes.bounds
        layer1.position = shapes.center
        shapes.layer.addSublayer(layer1)
        shapes.layer.cornerRadius = 99
        shapes.layer.borderWidth = 1
        shapes.layer.borderColor = UIColor(red: 0.93, green: 0.94, blue: 0.96, alpha: 1).cgColor
        
        gemaraButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setHeaderShadow() {
        let shadows = UIView()
        shadows.frame = headerShadowBasis.frame
        shadows.clipsToBounds = false
        headerShadowBasis.addSubview(shadows)
        
        let shadowPath0 = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: 0)
        
        let layer0 = CALayer()
        layer0.shadowPath = shadowPath0.cgPath
        layer0.shadowColor = UIColor(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.07).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 22
        layer0.shadowOffset = CGSize(width: 0, height: 4)
        layer0.bounds = shadows.bounds
        layer0.position = shadows.center
        shadows.layer.addSublayer(layer0)
        headerShadowBasis.translatesAutoresizingMaskIntoConstraints = false
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
