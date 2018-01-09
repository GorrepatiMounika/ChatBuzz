//
//  OTPViewController.swift
//  ChatBuzz
//
//  Created by Flashmac2 on 09/12/17.
//  Copyright © 2017 Flashmac2. All rights reserved.
//

import UIKit

class OTPViewController: UIViewController {

    @IBOutlet var otpTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func validateButtonClickAction(_ sender: Any) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let homePageViewController = storyBoard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController
        self.present(homePageViewController!, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
