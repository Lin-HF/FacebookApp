//
//  EditVC.swift
//  Facebook
//
//  Created by David on 1/7/19.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

class EditVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    //ui obj
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var firstNameTextFiled: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var addBioButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var friendsSwitch: UISwitch!
    @IBOutlet weak var followSwitch: UISwitch!
    
    //code obj
    var isCover = false
    var isAva = false
    var imageViewTapped = ""
    var isPasswordChanged = false
    var isAvaChanged = false
    var isCoverChanged = false
    //code obj
    var datePicker: UIDatePicker!
    var genderPicker: UIPickerView!
    let genderPickerValues = ["Male", "Female"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //assign full name to textfileds
        
        
        configure_avaImageView()
        loadUser()
        
        // implement datePicker into Birthday textfield
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())
        datePicker.addTarget(self, action: #selector(self.datePickerDidChange(_:)), for: .valueChanged)
        birthdayTextField.inputView = datePicker
        
        //create and configure gender picker view for gender TextField
        genderPicker = UIPickerView()
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderTextField.inputView = genderPicker
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configure_addBioButton()
    }
    
    func loadUser() {
        print(currentUser)
        
        // safe method of accessing user related information in glob var
        guard let firstName = currentUser?["firstName"],
            let lastName = currentUser?["lastName"],
            let email = currentUser?["email"],
            let birthday = currentUser?["birthday"] as? String,
            let gender = currentUser?["gender"] as? String,
            let avaPath = currentUser?["ava"],
            let coverPath = currentUser?["cover"]
            else {
                return
        }
        print("Get the information \(firstName) \(lastName)")
        
        guard let allow_friends = currentUser?["allow_friends"] as? String,
            let allow_follow = currentUser?["allow_follow"] as? String else {
                return
        }
        
        
        //check if there is ava and cover
        if (avaPath as! String).count > 10 {
            isAva = true
        } else {
            avaImageView.image = UIImage(named: "user.png")
            isAva = false
        }
        if (coverPath as! String).count > 10 {
            isCover = true
        } else {
            coverImageView.image = UIImage(named: "HomeCover.jpg")
            isCover = false
        }
        
        if Int(allow_friends) == 0 {
            friendsSwitch.isOn = false
        }
//        } else {
//            friendsSwitch.isOn = true
//        }
        if Int(allow_follow) == 0 {
            followSwitch.isOn = false
        }
        
        
        firstNameTextFiled.text = (firstName as! String).capitalized
        lastNameTextField.text = (lastName as! String).capitalized
        emailTextField.text = "\(email)"
        //birthdayTextField.text = "\(birthday)"
        //genderTextField.text = "\(gender)"
        
        Helper().downloadImage(path: avaPath as! String, showIn: self.avaImageView, orShow: "user.png")
        Helper().downloadImage(path: coverPath as! String, showIn: self.coverImageView, orShow: "HomeCover.jpg")
        
        //STEP 1. To show the Date in the UI format
        let formatterGet = DateFormatter()
        formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss zzzz"
        let date = formatterGet.date(from: birthday)!
        
        // STEP 2. declare a new format
        let formatterShow = DateFormatter()
        formatterShow.dateFormat = "MMM dd, yyyy"
        
        birthdayTextField.text = formatterShow.string(from: date)
        
        // Change gender from "1" to "Male"
        if gender == "1" {
            genderTextField.text = "Male"
        } else {
            genderTextField.text = "Female"
        }
    }
    
    
    func configure_avaImageView() {
        
        //create a layer that will applied to avaImageView
        let border = CALayer()
        border.borderColor = UIColor.white.cgColor
        border.borderWidth = 5
        border.frame = CGRect(x: 0, y: 0, width: avaImageView.frame.width, height: avaImageView.frame.height)
        avaImageView.layer.addSublayer(border)
        
        //rounded corners
        avaImageView.layer.cornerRadius = 10
        avaImageView.layer.masksToBounds = true
        avaImageView.clipsToBounds = true
    }
    
    //configure appearance of Add Bio Button
    func configure_addBioButton() {
        
        //border constant
        let border = CALayer()
        //64 107 174
        border.borderColor = UIColor.lightGray.cgColor
        border.borderWidth = 2
        border.frame = CGRect(x: 0, y: 0, width: addBioButton.frame.width, height: addBioButton.frame.height)
        
        // assign border to the obj (button)
        addBioButton.layer.addSublayer(border)
        
        // rounded corner
        addBioButton.layer.cornerRadius = 5
        addBioButton.layer.masksToBounds = true
        
    }

    // when cover tapped
    @IBAction func coverImageViewtapped(_ sender: Any) {
        imageViewTapped = "cover"
        showActionSheet()
        
    }
    
    //when ava tapped
    @IBAction func avaImageView_tapped(_ sender: Any) {
        imageViewTapped = "ava"
        showActionSheet()
    }
    
    // this function lanches Action sheet
    func showActionSheet() {
        
        // declaring action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // declaring camera button
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            // if camera available on device
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.showPicker(with: .camera)
            }
        }
        
        //declaring library button
        let library = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            // if photolibrary available
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.showPicker(with: .photoLibrary)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //declaring delete button
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            // deleting profile picture (ava)
            if self.imageViewTapped == "ava" {
                self.avaImageView.image = UIImage(named: "user.png")
                self.isAva = false
                self.isAvaChanged = true
            } else if self.imageViewTapped == "cover" {
                self.coverImageView.image = UIImage(named: "HomeCover.jpg")
                self.isCover = false
                self.isCoverChanged = true
            }
        }
        
        // when the picture is default, it can't be deleted
        if imageViewTapped == "ava" && isAva == false && imageViewTapped != "cover" {
            delete.isEnabled = false
        }
        if imageViewTapped == "cover" && isCover == false && imageViewTapped != "ava" {
            delete.isEnabled = false
        }
        
        //add buttons to the sheet
        sheet.addAction(camera)
        sheet.addAction(library)
        sheet.addAction(cancel)
        sheet.addAction(delete)
        
        // present action sheet to the user finally
        self.present(sheet, animated: true, completion: nil)
    }
    
    func showPicker(with source:UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
    }
    
    //excuted once the picture is selected in PickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        // based on the trigger cover or ava to change picture
        if imageViewTapped == "cover" {
            //aasign selected image to CoverImageView
            self.coverImageView.image = image
            //upload image to the server
            //self.uploadImage(from: self.coverImageView)
        } else if imageViewTapped == "ava" {
            //assign selected image to avaImageView
            self.avaImageView.image = image
            //upload image to the server
            //self.uploadImage(from: self.avaImageView)
        }
        
        // completion handler
        dismiss(animated: true) {
            if self.imageViewTapped == "cover" {
                self.isCover = true
                self.isCoverChanged = true
            } else if self.imageViewTapped == "ava" {
                self.isAva = true
                self.isAvaChanged = true
            }
        }
    }
    
    //executed whenever connected textfield has been changed
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        
        // tracking is password changed or not
        if textField == passwordTextField {
            isPasswordChanged = true
        }
    }
    // func will be excuted whenever any date is changed
    @objc func datePickerDidChange(_ datePicker: UIDatePicker) {
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        birthdayTextField.text = formatter.string(from: datePicker.date)

    }
    
    //number of columns in the picker "Male"
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //number of rows in the gender picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderPickerValues.count
    }
    
    //title for the row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderPickerValues[row]
    }
    
    //executed when picker selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = genderPickerValues[row]
        genderTextField.resignFirstResponder()
    }
    
    // save button
    @IBAction func saveButton_clicked(_ sender: Any) {
        updateUser()

        // updating ava and cover at the same time (first update ava, then update cover)
        if isAvaChanged == true && isCoverChanged == true {
            
            // upload ava
            uploadImage(from: avaImageView, type: "ava") {
                
                // in completion handler we upload cover
                self.uploadImage(from: self.coverImageView, type: "cover", completion: {
                    
                    // in 2nd completion handler we show alert message
                    Helper().showAlert(title: "Success!", message: "Cover and Ava have been updated", showIn: self)
                })
                
            }
            
        } else if isAvaChanged == true {
                uploadImage(from: avaImageView, type: "ava") {
                    Helper().showAlert(title: "Success!", message: "Ava has been updated", showIn: self)
                }
        } else  if isCoverChanged == true {
            uploadImage(from: coverImageView, type: "cover") {
                Helper().showAlert(title: "Success!", message: "Cover has been updated", showIn: self)
            }
        }
        
        
        
        //dismiss(animated: true, completion: nil)
    }
    
    func updateUser() {
        
        //get all params
        guard let id = currentUser?["id"] else {
            return
        }
        let email = emailTextField.text!
        let firstName = firstNameTextFiled.text!
        let lastName = lastNameTextField.text!
        let birthday = datePicker.date
        let password = passwordTextField.text!
        var gender = ""
        
        if genderTextField.text == "Male" {
            gender = "1"
        } else {
            gender = "2"
        }
        
        var allow_friends = ""
        if friendsSwitch.isOn == true {
            allow_friends = "1"
        } else {
            allow_friends = "0"
        }
        
        var allow_follow = ""
        if followSwitch.isOn == true {
            allow_follow = "1"
        } else {
            allow_friends = "0"
        }
        
        //logic of validation
        if Helper().isValid(email: email) == false {
            Helper().showAlert(title: "Invalid Email", message: "Please use valid E-mail address", showIn: self)
        } else if Helper().isValid(name: firstName) == false {
            Helper().showAlert(title: "Invalid name", message: "Please use valid name", showIn: self)
        } else if Helper().isValid(name: lastName) == false {
            Helper().showAlert(title: "Invalid surname", message: "Please use valid surname", showIn: self)
        } else if password.count < 6 {
            Helper().showAlert(title: "Invalid Password", message: "Password must contain at least 6 characters", showIn: self)
        }
        
        //prepare request
        let url = URL(string: "http://" + serverIP + "/fb/updateUser.php")!
        let body = "id=\(id)&email=\(email)&firstName=\(firstName)&lastName=\(lastName)&birthday=\(birthday)&gender=\(gender)&newPassword=\(isPasswordChanged)&password=\(password)&allow_friends=\(allow_friends)&allow_follow=\(allow_follow)"
        print(body)
        var request = URLRequest(url: url);
        request.httpMethod = "POST";
        request.httpBody = body.data(using: .utf8)
        
        //send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, showIn: self)
                }
                
                do {
                    
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, showIn: self)
                        return
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    guard let parsedJSON = json else {
                        return
                    }
                    
                    if parsedJSON["status"] as! String == "200" {
                        currentUser = parsedJSON.mutableCopy() as? NSMutableDictionary
                        UserDefaults.standard.set(currentUser, forKey: "currentUser")
                        UserDefaults.standard.synchronize()
                        
                        Helper().showAlert(title: "Success!", message: "Information has been saved!", showIn: self)
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUser"), object: nil)
                    }
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                    return
                }
                
            }
            
        }.resume()
            
    }
    
    // sends request to the server to upload the Image (ava/cover)
    func uploadImage(from imageView: UIImageView, type: String, completion: @escaping () -> Void) {
        
        // save method of accessing ID of current user
        guard let id = currentUser?["id"] else {
            return
        }
        
        // STEP 1. Declare URL, Request and Params
        // url we gonna access (API)
        let url = URL(string: "http://" + serverIP + "/fb/uploadImage.php")!
        
        // declaring reqeust with further configs
        var request = URLRequest(url: url)
        
        // POST - safest method of passing data to the server
        request.httpMethod = "POST"
        
        // values to be sent to the server under keys (e.g. ID, TYPE)
        let params = ["id": id, "type": type]
        
        // MIME Boundary, Header
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Compressing image and converting image to 'Data' type
        var imageData = Data()
        
        if imageView.image != UIImage(named: "HomeCover.jpg") && imageView.image != UIImage(named: "user.png") {
            imageData = imageView.image!.jpegData(compressionQuality: 0.5)!
        }
        
        // assigning full body to the request to be sent to the server
        request.httpBody = Helper().body(with: params, filename: "\(type).jpg", filePathKey: "file", imageDataKey: imageData, boundary: boundary) as Data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error occured
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, showIn: self)
                    return
                }
                
                
                do {
                    
                    // save mode of casting any data
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, showIn: self)
                        return
                    }
                    
                    // fetching JSON generated by the server - php file
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // save method of accessing json constant
                    guard let parsedJSON = json else {
                        return
                    }
                    
                    // uploaded successfully
                    if parsedJSON["status"] as! String == "200" {
                        
                        // saving updated information
                        currentUser = parsedJSON.mutableCopy() as? NSMutableDictionary
                        UserDefaults.standard.set(currentUser, forKey: "currentUser")
                        UserDefaults.standard.synchronize()
                        // sending notification to other vcs
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUser"), object: nil)
                    } else {
                        
                        // show the error message in AlertView
                        if parsedJSON["message"] != nil {
                            let message = parsedJSON["message"] as! String
                            Helper().showAlert(title: "Error", message: message, showIn: self)
                        }
                        
                    }
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                }
                
            }
            }.resume()
        
    }

    //When cancel button clicked
    @IBAction func cancelButton_clicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
