//
//  ViewController.swift
//  ChatBuzz
//
//  Created by Flashmac2 on 09/12/17.
//  Copyright © 2017 Flashmac2. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var usernameTextField: UITextField!
    
    @IBOutlet var phonenumberTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func loginButtonClickAction(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let otpViewController = storyBoard.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController
        self.present(otpViewController!, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

