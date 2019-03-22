//
//  RegisterVC.swift
//  Facebook
//
//  Created by David on 2018/11/19.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {
    
    // constraints objects
    @IBOutlet weak var contentView_width: NSLayoutConstraint!
    @IBOutlet weak var emailView_width: NSLayoutConstraint!
    @IBOutlet weak var nameView_width: NSLayoutConstraint!
    @IBOutlet weak var passwordView_width: NSLayoutConstraint!
    @IBOutlet weak var birthdayView_width: NSLayoutConstraint!
    @IBOutlet weak var genderView_width: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    
    @IBOutlet weak var emailContinueButton: UIButton!
    @IBOutlet weak var fullnameContinueButton: UIButton!
    @IBOutlet weak var passwordContinueButton: UIButton!
    @IBOutlet weak var birthdayContinueButton: UIButton!
    @IBOutlet weak var femaleGenderButton: UIButton!
    @IBOutlet weak var maleGenderButton: UIButton!
    
    
    @IBOutlet weak var footerView: UIView!
    
    //code obj
    var datePicker: UIDatePicker!
    
    
    // first loading function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // adjust of the views ofto the screen of the device
        contentView_width.constant = self.view.frame.width * 5
        
        emailView_width.constant = self.view.frame.width
        nameView_width.constant = self.view.frame.width
        passwordView_width.constant = self.view.frame.width
        birthdayView_width.constant = self.view.frame.width
        genderView_width.constant = self.view.frame.width
        
        // make corners of the objects rounded
        cornerRadius(for: emailTextField)
        cornerRadius(for: firstNameTextField)
        cornerRadius(for: lastNameTextField)
        cornerRadius(for: passwordTextField)
        cornerRadius(for: birthdayTextField)
        cornerRadius(for: emailContinueButton)
        cornerRadius(for: fullnameContinueButton)
        cornerRadius(for: passwordContinueButton)
        cornerRadius(for: birthdayContinueButton)
        
        // make paddings to textFields
        padding(for: emailTextField)
        padding(for: firstNameTextField)
        padding(for: lastNameTextField)
        padding(for: passwordTextField)
        padding(for: birthdayTextField)
        
        // add line at the footer
        configure_footerView()
        
        // implement datePicker into Birthday textfield
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())
        datePicker.addTarget(self, action: #selector(self.datePickerDidChange(_:)), for: .valueChanged)
        birthdayTextField.inputView = datePicker
        
        // implementation of swip gesture
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handle(_:)))
        swipe.direction = .right
        self.view.addGestureRecognizer(swipe)
        
        //implementation of tap white space cancel keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.disssmissKeyboard))
        self.view.addGestureRecognizer(tap)
        
    }
    
    // executed once the Auto-Layout has been applied
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        // Gender button appearence
//        configure_button(gender: femaleGenderButton)
//        configure_button(gender: maleGenderButton)
        
        DispatchQueue.main.async {
            // Gender button appearence
            self.configure_button(gender: self.femaleGenderButton)
            self.configure_button(gender: self.maleGenderButton)
        }
        
    }
    
    // make corners rounded for any views
    func cornerRadius(for view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
    }
    
    // add blank view to the left side of the TextField (gap)
    func padding(for textField: UITextField) {
        let blankView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        textField.leftView = blankView
        textField.leftViewMode = .always
    }
    
    func configure_footerView() {
        
        // adding the line at the footerView
        let topline = CALayer()
        topline.borderWidth = 1
        topline.borderColor = UIColor.lightGray.cgColor
        topline.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1)
        
        footerView.layer.addSublayer(topline)
    }
    
    //configuring the apperance of gender buttons
    func configure_button(gender button: UIButton) {
        
        // create constant of border
        let border = CALayer()
        border.borderWidth = 1.5
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: 0, width: button.frame.width, height: button.frame.height)
        
        // aasign the layer
        button.layer.addSublayer(border)
        
        // make corner rounded
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
    }
    

    
    // textfield changed
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        
        // validation helper class
        let helper = Helper()
        
        // email validation
        if textField == emailTextField {
            if helper.isValid(email: emailTextField.text!) {
                emailContinueButton.isHidden = false
            }
        }
        // name validation
        else if textField == firstNameTextField || textField == lastNameTextField {
            if helper.isValid(name: firstNameTextField.text!) && helper.isValid(name: lastNameTextField.text!) {
                fullnameContinueButton.isHidden = false
            }
        }
        // password validation
        else if textField == passwordTextField {
            if passwordTextField.text!.count >= 6 {
                passwordContinueButton.isHidden = false
            }
        }
        
    }
    
    @IBAction func emailContinueButton_clicked(_ sender: UIButton) {
        // move scrollView horizontally
        let position = CGPoint(x: self.view.frame.width, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        // show new keyboard
        if firstNameTextField.text!.isEmpty {
            firstNameTextField.becomeFirstResponder()
        } else if lastNameTextField.text!.isEmpty {
            lastNameTextField.becomeFirstResponder()
        } else if firstNameTextField.text!.isEmpty == false && lastNameTextField.text!.isEmpty == false {
            firstNameTextField.resignFirstResponder()
            lastNameTextField.resignFirstResponder()
        }
    }
    
    
    @IBAction func fullNameContinueButton_clicked(_ sender: UIButton) {
        
        // move scrollView horizontally
        let position = CGPoint(x: self.view.frame.width * 2, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        if passwordTextField.text!.isEmpty {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.text!.isEmpty == false {
            passwordTextField.resignFirstResponder()
        }
    }
    
    @IBAction func passwordContinueButton_clicked(_ sender: UIButton) {
        
        // move scrollView horizontally
        let position = CGPoint(x: self.view.frame.width * 3, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        if birthdayTextField.text!.isEmpty {
            birthdayTextField.becomeFirstResponder()
        } else {
            birthdayTextField.resignFirstResponder()
        }
    }
    
    // func will be excuted whenever any date is changed
    @objc func datePickerDidChange(_ datePicker: UIDatePicker) {
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        birthdayTextField.text = formatter.string(from: datePicker.date)
        
        let compareDateFormatter = DateFormatter()
        compareDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let compareDate = compareDateFormatter.date(from: "2013/01/01 00:01")
        
        if datePicker.date < compareDate! {
            birthdayContinueButton.isHidden = false
        } else {
            birthdayContinueButton.isHidden = true
        }
    }
    
    @IBAction func birthdayContinueButton_clicked(_ sender: UIButton) {
        // move scrollView horizontally
        let position = CGPoint(x: self.view.frame.width * 4, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        birthdayTextField.resignFirstResponder()
    }
    
    // called once Swiped to the direction  Right ->
    @objc func handle(_ gesture: UISwipeGestureRecognizer) {
        
        // getting current position of the scrollview
        let current_x = scrollView.contentOffset.x
        // get width of screen
        let screen_width = self.view.frame.width
        // new position
        let new_x = CGPoint(x: current_x - screen_width, y: 0)
        
        // first page don't change
        if current_x > 0 {
            scrollView.setContentOffset(new_x, animated: true)
        }
    }
    
    @objc func disssmissKeyboard() {
        emailTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        birthdayTextField.resignFirstResponder()
    }
    
    
    // This function is excuted whenever Male/Female button is clicked
    @IBAction func genderButton_clicked(_ sender: UIButton) {
        
        // STEP.1 declaring url of request
        let url = URL(string: "http://" + serverIP + "/fb/register.php")!
        let body = "email=\(emailTextField.text!.lowercased())&firstName=\(firstNameTextField.text!.lowercased())&lastName=\(lastNameTextField.text!.lowercased())&password=\(passwordTextField.text!)&birthday=\(datePicker.date)&gender=\(sender.tag)"
        //print(body)
        var request = URLRequest(url: url)
        request.httpBody = body.data(using: .utf8)
        request.httpMethod = "POST" //Safe
        
        //STEP.2 excuring
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            let helper = Helper()
            if error != nil {
                
                helper.showAlert(title: "Server Error", message: error!.localizedDescription, showIn: self)
                return
            }
            
            // fetch JSON if no error
            do {
                
                guard let data = data else {
                    helper.showAlert(title: "Data Error", message: error!.localizedDescription, showIn: self)
                    return
                }
                
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                
                guard let parsedJSON = json else {
                    print("Parsing Error")
                    return
                }
                
                //Successfully registered
                if parsedJSON["status"] as? String == "200" {
                    //Go to TabBar
                    helper.instantiateViewController(identifier: "TabBar", animated: true, by: self, completion: nil)
                    
                    //saving logged user
                    currentUser = parsedJSON.mutableCopy() as? NSMutableDictionary
                    UserDefaults.standard.set(currentUser, forKey: "currentUser")
                    UserDefaults.standard.synchronize()
                    print(currentUser)
                } else {
                    if let message = parsedJSON["message"] as! String? {
                        helper.showAlert(title: "Error", message: message, showIn: self)
                    }
                }
                
                
                //print(json)
                
            } catch {
                helper.showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
            }
            
        }.resume()
    }
    
    
    
    @IBAction func cancelButtonclicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
