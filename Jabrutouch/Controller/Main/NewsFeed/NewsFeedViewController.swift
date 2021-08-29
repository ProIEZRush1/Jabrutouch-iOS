//
//  NewsFeedViewController.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 26/08/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import UIKit

class NewsFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //============================================================
    // MARK: - Outlets
    //============================================================
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    //============================================================
    // MARK: - LifeCycle
    //============================================================
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    

    //============================================================
    // MARK: - Actions
    //============================================================
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //============================================================
    // MARK: - TableView
    //============================================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
    UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsItemCell", for: indexPath) as! NewsItemCell
    
        
//            NSLayoutConstraint.deactivate(cell.imageBox.constraints)
        cell.imageBox.isHidden = [1,3,5].contains(indexPath.row)
        cell.textContainer.isHidden = [4,6,8].contains(indexPath.row)
      
        Utils.setViewShape(view: cell.newsItemView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0.0, height: 5)
        Utils.dropViewShadow(view: cell.newsItemView, shadowColor: Colors.shadowColor, shadowRadius: 15 , shadowOffset: shadowOffset)
        cell.newsItemView.layoutIfNeeded()
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
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
