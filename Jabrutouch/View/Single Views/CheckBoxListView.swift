//
//  CheckBoxListView.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 19/10/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import UIKit

final class CheckBoxListView: UIView {

    var checkboxes: [CheckBoxView] = []
    let stackview: UIStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.stackview.frame = self.bounds
        self.addSubview(self.stackview)
    }
    
    func setupCheckBoxes(data: [String]){
        for item in data {
            let cBox = CheckBoxView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            self.stackview.addSubview(cBox)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("fatalEror in CheckBoxListView")
    }
    
}

final class CheckBoxView: UIView {

    var isChecked: Bool = false
    var title:String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = frame.size.width / 2.0
        backgroundColor = .white
    }
    
    func toggle(){
        self.isChecked = !self.isChecked
        
        if self.isChecked {
            backgroundColor = .systemBlue
        }
        else {
            backgroundColor = .white
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("fatalEror in CheckBoxView")
    }
    
}
