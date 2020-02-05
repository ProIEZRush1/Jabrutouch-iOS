//בעזרת ה׳ החונן לאדם דעת
//  Storyboards.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 04/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class Storyboards {
    
    class WalkThrough {
        private class func walkThroughStoryboard() -> UIStoryboard { return UIStoryboard(name: "WalkThrough", bundle: Bundle.main) }
        
        class var  walkThroughViewController: WalkThroughViewController {
            return self.walkThroughStoryboard().instantiateViewController(withIdentifier: "WalkThroughViewController") as! WalkThroughViewController
        }
    }
    
    class SignIn {
        private class func signInStoryboard() -> UIStoryboard { return UIStoryboard(name: "SignIn", bundle: Bundle.main) }
        
        class var  signInViewController: SignInViewController {
            return self.signInStoryboard().instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        }
    }
    
    class Main {
        private class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
        
        class var  mainViewController: MainViewController {
            return self.mainStoryboard().instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        }
        
        class var aboutViewController: AboutViewController {
            return self.mainStoryboard().instantiateViewController(withIdentifier: "AboutVC") as! AboutViewController
        }
    }
    
    class Gallery {
        private class func galleryStoryboard() -> UIStoryboard { return UIStoryboard(name: "Gallery", bundle: Bundle.main) }
        
        class var  galleryViewController: GalleryViewController {
            return self.galleryStoryboard().instantiateViewController(withIdentifier: "GalleryViewController") as! GalleryViewController
        }
    }
    
    class Donation {
        private class func donationStoryboard() -> UIStoryboard { return UIStoryboard(name: "Donations", bundle: Bundle.main) }
        
        class var  donateNavigationController: DonateNavigationController {
            return self.donationStoryboard().instantiateViewController(withIdentifier: "DonateNavigationController") as! DonateNavigationController
        }
    }
}
