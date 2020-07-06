//
//  DonatedAlert.swift
//  Jabrutouch
//
//  Created by yacov sofer on 05/09/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

protocol DonatedAlertDelegate: class {
    func didDismiss()
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
    
    func setDonor() {
        let allDonors: [JTDonor] = [JTDonor(firstName: "Simon", lastName: "Hanono", country: "México"),
                                    JTDonor(firstName: "José", lastName: "Ezban", country: "México"),
                                    JTDonor(firstName: "Daniel", lastName: "Ezban", country: "México"),
                                    JTDonor(firstName: "Moises", lastName: "Askenazi", country: "México"),
                                    JTDonor(firstName: "Moises", lastName: "Esses", country: "México"),
                                    JTDonor(firstName: "Abraham", lastName: "Hamui", country: "México"),
                                    JTDonor(firstName: "Abraham", lastName: "Askenazi", country: "México"),
                                    JTDonor(firstName: "Zury", lastName: "Esses", country: "México"),
                                    JTDonor(firstName: "José", lastName: "Amkie", country: "México"),
                                    JTDonor(firstName: "Marcos", lastName: "Ohana", country: "Argentina"),
                                    JTDonor(firstName: "Jacobo", lastName: "Cojab", country: "México"),
                                    JTDonor(firstName: "Mauricio", lastName: "Cojab", country: "México"),
                                    JTDonor(firstName: "Eduardo", lastName: "Alfie", country: "México"),
                                    JTDonor(firstName: "Sarah", lastName: "Serfaty", country: "Israel"),
                                    JTDonor(firstName: "Mayer", lastName: "Cherem", country: "Panamá"),
                                    JTDonor(firstName: "Menahem", lastName: "Nidam", country: "España"),
                                    JTDonor(firstName: "Manuel", lastName: "Roditi", country: "México"),
                                    JTDonor(firstName: "Ezra", lastName: "Cohen", country: "Panamá"),
                                    JTDonor(firstName: "Moises", lastName: "Saba", country: "México"),
                                    JTDonor(firstName: "Daniel", lastName: "Saba", country: "México"),
                                    JTDonor(firstName: "Nessim", lastName: "Cojab", country: "Argentina"),
                                    JTDonor(firstName: "Abraham", lastName: "Benzadon", country: "Venezuela"),
                                    JTDonor(firstName: "Isaac", lastName: "Sutton", country: "Brasil"),
                                    JTDonor(firstName: "Abraham", lastName: "Bendahan", country: "U.S.A."),
                                    JTDonor(firstName: "Emilio", lastName: "Benzadon", country: "U.S.A."),
                                    JTDonor(firstName: "Moses", lastName: "Garson", country: "Inglaterra"),
                                    JTDonor(firstName: "Arie", lastName: "Cohen", country: "Chile"),
                                    JTDonor(firstName: "Familia", lastName: "Benaim", country: "Gibraltar"),
                                    JTDonor(firstName: "Jacob", lastName: "Benzadon", country: "España"),
                                    JTDonor(firstName: "Isaac", lastName: "Nidam", country: "España"),
                                    JTDonor(firstName: "Mercedes", lastName: "Pilo", country: "España"),
                                    JTDonor(firstName: "Julia B.", lastName: "Nidam", country: "España"),
                                    JTDonor(firstName: "Victor M.", lastName: "Azrak", country: "Panamá"),
                                    JTDonor(firstName: "Moises", lastName: "Azrak", country: "Panamá"),
                                    JTDonor(firstName: "David", lastName: "Azrak", country: "Panamá"),
                                    JTDonor(firstName: "Michael", lastName: "Harari", country: "Panamá"),
                                    JTDonor(firstName: "Max Joe", lastName: "Harari", country: "Panamá"),]
        
        
        var index = UserDefaultsProvider.shared.index
        if index == allDonors.count {
            UserDefaultsProvider.shared.index = 0
            index = 0
        } else {
            UserDefaultsProvider.shared.index = index + 1
        }
        self.nameLabel.text = "\(allDonors[index].firstName) \(allDonors[index].lastName)"
        self.location.text = allDonors[index].country
        
    }
    
    //====================================================
    // MARK: - @IBActions
    //====================================================
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.didDismiss()
        }
    }
    
}
