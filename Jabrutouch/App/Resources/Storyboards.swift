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
    
    class TourWalkThrough {
        private class func tourWalkThroughStoryboard() -> UIStoryboard { return UIStoryboard(name: "TourWalkThrough", bundle: Bundle.main) }
        
        class var  welcomeTourViewController: WelcomeTourViewController {
            return self.tourWalkThroughStoryboard().instantiateViewController(withIdentifier: "welcomeTourViewController") as! WelcomeTourViewController
        }
        
        class var  tourWalkThroughViewController: TourWalkThroughViewController {
            return self.tourWalkThroughStoryboard().instantiateViewController(withIdentifier: "tourWalkThroughViewController") as! TourWalkThroughViewController
        }
    }
    
    class DonationWalkThrough {
        private class func donationsWalkThroughStoryboard() -> UIStoryboard { return UIStoryboard(name: "DonationWalkThrough", bundle: Bundle.main) }
        
        class var  welcomeDonationViewController: WelcomeDonationViewController {
            return self.donationsWalkThroughStoryboard().instantiateViewController(withIdentifier: "welcomeDonationViewController") as! WelcomeDonationViewController
        }
        
        class var  donationsWalkThroughViewController: DonationsWalkThroughViewController {
            return self.donationsWalkThroughStoryboard().instantiateViewController(withIdentifier: "donationsWalkThroughViewController") as! DonationsWalkThroughViewController
        }
    }
    
    class DonationPopUp{
        private class func donationsPopUpStoryboard() -> UIStoryboard { return UIStoryboard(name: "DonationPopUps", bundle: Bundle.main) }
        
        class var  donationPopUpViewController: DonationPopUpViewController {
            return self.donationsPopUpStoryboard().instantiateViewController(withIdentifier: "donationPopUpViewController") as! DonationPopUpViewController
        }
        class var  lastPopUp: DonationLastPopUpViewController {
            return self.donationsPopUpStoryboard().instantiateViewController(withIdentifier: "donationLastPopUpViewController") as! DonationLastPopUpViewController
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
    
    class PopUp {
        private class func popUpStoryboard() -> UIStoryboard { return UIStoryboard(name: "PopUps", bundle: Bundle.main) }
        
        class var  popUpViewController: PopUpViewController {
            return self.popUpStoryboard().instantiateViewController(withIdentifier: "popup") as! PopUpViewController
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
    
    class Gemara {
        private class func gemaraStoryboard() -> UIStoryboard { return UIStoryboard(name: "Gemara", bundle: Bundle.main) }
        
        class var  gemaraViewController: GemaraViewController {
            return self.gemaraStoryboard().instantiateViewController(withIdentifier: "GemaraViewController") as! GemaraViewController
        }
    }
    
    class Mishna {
        private class func mishnaStoryboard() -> UIStoryboard { return UIStoryboard(name: "Mishna", bundle: Bundle.main) }
        
        class var  mishnaViewController: MishnaViewController {
            return self.mishnaStoryboard().instantiateViewController(withIdentifier: "MishnaViewController") as! MishnaViewController
        }
    }
    
    class Download {
        private class func downloadStoryboard() -> UIStoryboard { return UIStoryboard(name: "Download", bundle: Bundle.main) }
        
        class var  downloadsNavigationController: DownloadsNavigationController {
            return self.downloadStoryboard().instantiateViewController(withIdentifier: "DownloadsNavigationController") as! DownloadsNavigationController
        }
    }
    
    class Messages {
        private class func messagesStoryboard() -> UIStoryboard { return UIStoryboard(name: "Messages", bundle: Bundle.main) }
        
        class var  messagesNavigationController: MessagesNavigationController {
            return self.messagesStoryboard().instantiateViewController(withIdentifier: "MessagesNavigationController") as! MessagesNavigationController
        }
    }
}
