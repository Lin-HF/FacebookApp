//
//  LoginVC.swift
//  Facebook
//
//  Created by David on 2018/11/19.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    // ui obj
    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var leftLineView: UIView!
    @IBOutlet weak var rightLineView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var handsImageView: UIImageView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // constraints obj
    @IBOutlet weak var coverImageView_top: NSLayoutConstraint!
    @IBOutlet weak var whiteIconImageView_y: NSLayoutConstraint!
    @IBOutlet weak var handsImageView_top: NSLayoutConstraint!
    @IBOutlet weak var registerButton_bottom: NSLayoutConstraint!
    
    // cache obj
    var coverImageView_top_cache: CGFloat!
    var whiteIconImageView_y_cache: CGFloat!
    var handsImageView_top_cache: CGFloat!
    var registerButton_bottom_cache: CGFloat!
    
    // animation flag
    var animated = false
    
    // executed when the scene is loaded
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // caching all values of constraint
        coverImageView_top_cache = coverImageView_top.constant
        whiteIconImageView_y_cache = whiteIconImageView_y.constant
        handsImageView_top_cache = handsImageView_top.constant
        registerButton_bottom_cache = registerButton_bottom.constant
    }
    
    // executed everytime when view did appear on the screen
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // declaring notification observation in order to catch UIKeyboardWillShow notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //switch off notification center
        NotificationCenter.default.removeObserver(self)
    }
    
    // executed always when the Screen's white space (anywhere excluding objects) tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //end editinf - hide keyboard
        self.view.endEditing(false)
    }
    
    
    // executed once the kyboard is about ti be shown
    @objc func keyboardWillShow(notification: Notification) {
        if animated {
            return
        } else {
            animated = true
        }
        //deducting 75pxls from current Y position (doesn't action till forced)
        coverImageView_top.constant -= 75
        handsImageView_top.constant -= 75
        whiteIconImageView_y.constant += 50
        
//        coverImageView_top.constant -= self.view.frame.width / 5.52
//        handsImageView_top.constant -= self.view.frame.width / 5.52
//        whiteIconImageView_y.constant += self.view.frame.width / 8.28
        
        // if iOS (app) is able to access keyboard's frame, then change Y position of the registration button
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            registerButton_bottom.constant += keyboardSize.height
            //registerButton_bottom.constant += self.view.frame.width / 1.75423
        }
        //registerButton_bottom.constant += 300
        
        // animation function. Whatever in the closure bellow will be animated
        UIView.animate(withDuration: 0.5) {
            self.handsImageView.alpha = 0
            // force to update the layout
            self.view.layoutIfNeeded()
        }
    }
    // executed once the keyboard is about to hidden
    @objc func keyboardWillHide(notification: Notification) {
        if !animated {
            return
        } else {
            animated = false
        }
        //deducting 75pxls from current Y position (doesn't action till forced)
        coverImageView_top.constant = coverImageView_top_cache
        handsImageView_top.constant = handsImageView_top_cache
        whiteIconImageView_y.constant = whiteIconImageView_y_cache
        
        // if iOS (app) is able to access keyboard's frame, then change Y position of the registration button
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            registerButton_bottom.constant -= keyboardSize.height
//        }
        registerButton_bottom.constant = registerButton_bottom_cache
        
        // animation function. Whatever in the closure bellow will be animated
        UIView.animate(withDuration: 0.5) {
            self.handsImageView.alpha = 1
            // force to update the layout
            self.view.layoutIfNeeded()
        }
    }
    
    // excuted after aligning the objects
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configure_textFieldsView()
        configure_loginBtn()
        configure_orLabel()
        configure_registerButton()
    }
    
    // this function stores code which configures appearence of textFields' view
    func configure_textFieldsView() {
        
        // declaring constants to store information which later on will be assigned to certain object
        let width = CGFloat(2)
        let color = UIColor.groupTableViewBackground.cgColor
        
        // border
        let border = CALayer()
        border.borderColor = color
        border.borderWidth = width
        border.frame = CGRect(x: 0, y: 0, width: textFieldsView.frame.width, height: textFieldsView.frame.height)
        
        // center line
        let line = CALayer()
        line.borderWidth = width
        line.borderColor = color
        line.frame = CGRect(x: 0, y: textFieldsView.frame.height / 2 - width, width: textFieldsView.frame.width, height: width)
        
        // assigning created layers to the view
        textFieldsView.layer.addSublayer(border)
        textFieldsView.layer.addSublayer(line)
        
        // rounded corners
        textFieldsView.layer.cornerRadius = 5
        textFieldsView.layer.masksToBounds = true
    }

    // will configure login buttons
    func configure_loginBtn() {
        loginButton.layer.cornerRadius = 5
        loginButton.layer.masksToBounds = true
        //loginButton.isEnabled = false
    }
    
    // will configure apperance of OR lable and its views storing the lines
    func configure_orLabel() {
        
        // shortcuts
        let width = CGFloat(2)
        //let color = UIColor.lightGray.cgColor
        let color = UIColor.groupTableViewBackground.cgColor
        
        // create left line object (layer)
        let leftLine = CALayer()
        leftLine.borderWidth = width
        leftLine.borderColor = color
        leftLine.frame = CGRect(x: 0, y: leftLineView.frame.height / 2 - width, width: leftLineView.frame.width, height: width)
        
        // create right line object (layer)
        let rightLine = CALayer()
        rightLine.borderWidth = width
        rightLine.borderColor = color
        rightLine.frame = CGRect(x: 0, y: rightLineView.frame.height / 2 - width, width: rightLineView.frame.width, height: width)
        
        // assign lines to the UI
        leftLineView.layer.addSublayer(leftLine)
        rightLineView.layer.addSublayer(rightLine)
    }
    
    func configure_registerButton() {
        
        //border constant
        let border = CALayer()
        //64 107 174
        border.borderColor = UIColor(red: 68/255, green: 105/255, blue: 176/255, alpha: 1).cgColor
        border.borderWidth = 2
        border.frame = CGRect(x: 0, y: 0, width: registerButton.frame.width, height: registerButton.frame.height)
        
        // assign border to the obj (button)
        registerButton.layer.addSublayer(border)
        
        // rounded corner
        registerButton.layer.cornerRadius = 5
        registerButton.layer.masksToBounds = true
        
    }
    
    // excuted when the button is pressed
    @IBAction func loginButton_clicked(_ sender: UIButton) {
        
        let helper = Helper()

        //if entered email or password is invalid, show alert
        // email validation
        if helper.isValid(email: loginTextField.text!) == false {
            helper.showAlert(title: "Invalid email", message: "Please enter registed Email address", showIn: self)
            return
        // password validation
        } else if (passwordTextField.text!.count < 6) {
            helper.showAlert(title: "Invalid password", message: "Password must contain at least 6 characters", showIn: self)
            return
        }
        
        //
        
        loginRequest()
        
    }
    
    // sending request to the server for proceeding Log In
    func loginRequest() {
        
        // STEP 1. declaring URL to be sent request to;
        //declaring the body to be apended to URL
        //declaring request to be excuted
        let url = URL(string: "http://" + serverIP + "/fb/login.php")!
        let body = "email=\(loginTextField.text!)&password=\(passwordTextField.text!)"
        
        var request = URLRequest(url: url)
        request.httpBody = body.data(using: .utf8)
        request.httpMethod = "POST"
        
        //Step 2. Excute created above request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                let helper = Helper()
                
                if error != nil {
                    helper.showAlert(title: "Server Error", message: error!.localizedDescription, showIn: self)
                    return
                }
                
                // STEP 3. Recieve JSON message
                do {
                    guard let data = data else {
                        helper.showAlert(title: "Data Error", message: error!.localizedDescription, showIn: self)
                        return
                    }
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // save mode of casting JSON
                    guard let parsedJSON = json else {
                        print("Parsing Error")
                        return
                    }
                    
                    // STEP 4. Create scenarios
                    if parsedJSON["status"] as? String == "200" {
                        //Go to TabBar
                        helper.instantiateViewController(identifier: "TabBar", animated: true, by: self, completion: nil)
                        
                        //saving logged user
                        currentUser = parsedJSON.mutableCopy() as? NSMutableDictionary
                        UserDefaults.standard.set(currentUser, forKey: "currentUser")
                        UserDefaults.standard.synchronize()
                        
                        
                    } else {
                        if let message = parsedJSON["message"] as! String? {
                            helper.showAlert(title: "Error", message: message, showIn: self)
                        }
                    }
                    
                    print(parsedJSON)
                } catch {
                    helper.showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                }
            }
            
            
        }.resume()
    }
}
