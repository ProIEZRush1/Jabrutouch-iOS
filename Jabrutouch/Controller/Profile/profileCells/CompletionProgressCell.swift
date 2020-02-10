//
//  CompletionProgressCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 22/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class CompletionProgressCell: UITableViewCell {

    @IBOutlet weak var completionPercentage: UILabel!
    @IBOutlet weak var progressView: JBProgressBar!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.progressView.layer.cornerRadius = self.progressView.bounds.height/2
//        self.progressView.layer.backgroundColor = #colorLiteral(red: 0.83, green: 0.86, blue: 0.91, alpha: 0.5)
        // Configure the view for the selected state
    }

}
