//
//  DonatedAlert.swift
//  Jabrutouch
//
//  Created by yacov sofer on 05/09/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

protocol DonatedAlertDelegate: class {
    func didDismiss(withDonation: Bool)
}

class DonatedAlert: UIViewController {
    
    //====================================================
    // MARK: - @IBOutlets
    //====================================================
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var dedicationLabel: UILabel!
    @IBOutlet weak var dedicationNameLabel: UILabel!
    
    //====================================================
    // MARK: - Properties
    //====================================================
    
    weak var delegate: DonatedAlertDelegate?
    var dedicationText: String = ""
    var dedicationNameText: String = ""
    var nameText: String = ""
    var locationText: String = ""
    
    //====================================================
    // MARK: - Life Cycle
    //====================================================
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStrings()
        self.setCornerRadius()
       self.setShadow()
//        self.setDonor()
//        self.getDonorText()

    }
    
    override func loadView() {
        Bundle.main.loadNibNamed("DonatedAlert", owner: self, options: nil)
    }
    
    //====================================================
    // MARK: - Setup
    //====================================================
    func setStrings() {
        self.titleLabel.text = Strings.donatedTitle
        let dedicationString = "\(self.dedicationText)"
        let dedicationNameString = "\(self.dedicationNameText)"
        if dedicationString.isEmpty && dedicationNameString.isEmpty{
            self.dedicationLabel.text = "Cuando termine la clase,"
            self.dedicationNameLabel.text = "regala ketarim tú también."
            self.dedicationLabel.font = self.dedicationLabel.font.withSize(18)
            self.dedicationNameLabel.font = self.dedicationNameLabel.font.withSize(18)
        } else {
            self.dedicationLabel.text = dedicationString
            self.dedicationNameLabel.text = dedicationNameString.uppercased()
        }
        self.location.text = self.locationText
        self.nameLabel.text = self.nameText
        self.startBtn.setTitle(Strings.donatedBtn, for: .normal)
    }
    
    func setCornerRadius() {
        self.mainView.layer.cornerRadius = 31
        self.startBtn.layer.cornerRadius = 18
        
    }
    
    func setShadow() {
        let shadowOffset = CGSize(width: 0.0, height: 20)
        let color = #colorLiteral(red: 0.16, green: 0.17, blue: 0.39, alpha: 0.5)
        Utils.dropViewShadow(view: self.mainView, shadowColor: color, shadowRadius: 31, shadowOffset: shadowOffset)
    }
    
//    func setDonor() {
//        let allDonors: [JTDonor] = [JTDonor(firstName: "Simon", lastName: "Hanono", country: "MX"),
//                                    JTDonor(firstName: "José", lastName: "Ezban", country: "MX"),
//                                    JTDonor(firstName: "Daniel", lastName: "Ezban", country: "MX"),
//                                    JTDonor(firstName: "Moises", lastName: "Askenazi", country: "MX"),
//                                    JTDonor(firstName: "Moises", lastName: "Esses", country: "MX"),
//                                    JTDonor(firstName: "Abraham", lastName: "Hamui", country: "MX"),
//                                    JTDonor(firstName: "Abraham", lastName: "Askenazi", country: "MX"),
//                                    JTDonor(firstName: "Zury", lastName: "Esses", country: "MX"),
//                                    JTDonor(firstName: "José", lastName: "Amkie", country: "MX"),
//                                    JTDonor(firstName: "Marcos", lastName: "Ohana", country: "AR"),
//                                    JTDonor(firstName: "Jacobo", lastName: "Cojab", country: "MX"),
//                                    JTDonor(firstName: "Mauricio", lastName: "Cojab", country: "MX"),
//                                    JTDonor(firstName: "Eduardo", lastName: "Alfie", country: "MX"),
//                                    JTDonor(firstName: "Sarah", lastName: "Serfaty", country: "IL"),
//                                    JTDonor(firstName: "Mayer", lastName: "Cherem", country: "PA"),
//                                    JTDonor(firstName: "Menahem", lastName: "Nidam", country: "ES"),
//                                    JTDonor(firstName: "Manuel", lastName: "Roditi", country: "MX"),
//                                    JTDonor(firstName: "Ezra", lastName: "Cohen", country: "PA"),
//                                    JTDonor(firstName: "Moises", lastName: "Saba", country: "MX"),
//                                    JTDonor(firstName: "Daniel", lastName: "Saba", country: "MX"),
//                                    JTDonor(firstName: "Nessim", lastName: "Cojab", country: "AR"),
//                                    JTDonor(firstName: "Abraham", lastName: "Benzadon", country: "VE"),
//                                    JTDonor(firstName: "Isaac", lastName: "Sutton", country: "BR"),
//                                    JTDonor(firstName: "Abraham", lastName: "Bendahan", country: "US"),
//                                    JTDonor(firstName: "Emilio", lastName: "Benzadon", country: "US"),
//                                    JTDonor(firstName: "Moses", lastName: "Garson", country: "GB"),
//                                    JTDonor(firstName: "Arie", lastName: "Cohen", country: "CL"),
//                                    JTDonor(firstName: "Familia", lastName: "Benaim", country: "GI"),
//                                    JTDonor(firstName: "Jacob", lastName: "Benzadon", country: "ES"),
//                                    JTDonor(firstName: "Isaac", lastName: "Nidam", country: "ES"),
//                                    JTDonor(firstName: "Mercedes", lastName: "Pilo", country: "ES"),
//                                    JTDonor(firstName: "Julia B.", lastName: "Nidam", country: "ES"),
//                                    JTDonor(firstName: "Victor M.", lastName: "Azrak", country: "PA"),
//                                    JTDonor(firstName: "Moises", lastName: "Azrak", country: "PA"),
//                                    JTDonor(firstName: "David", lastName: "Azrak", country: "PA"),
//                                    JTDonor(firstName: "Michael", lastName: "Harari", country: "PA"),
//                                    JTDonor(firstName: "Max Joe", lastName: "Harari", country: "PA"),]
//        
//        
//        var index = UserDefaultsProvider.shared.index
//        if index == allDonors.count {
//            UserDefaultsProvider.shared.index = 0
//            index = 0
//        } else {
//            UserDefaultsProvider.shared.index = index + 1
//        }
//        self.nameLabel.text = "\(allDonors[index].firstName) \(allDonors[index].lastName)"
//        self.location.text = allDonors[index].country
//        
//    }
    
    //====================================================
    // MARK: - @IBActions
    //====================================================
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.didDismiss(withDonation: true)
        }
    }
    
}
