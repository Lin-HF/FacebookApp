//
//  PostVC.swift
//  Facebook
//
//  Created by David on 1/6/19.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

class PostVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //ui obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    
    //code obj
    var isPictureSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUser()
        
    }
    
    //load after adjusting the layouts
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // ava round corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
    }
    
    func loadUser() {

        guard let firstName = currentUser?["firstName"], let lastName = currentUser?["lastName"], let avaPath = currentUser?["ava"] else {
            return
        }
        
        //fullNameLabel.text = "\((firstName as! String).capitalized) \((lastName as! String).capitalized)"
        
        // load full name
        Helper().loadFullName(firstName: firstName as! String, lastName: lastName as! String, showIn: fullNameLabel)
        
        //load ava image
        Helper().downloadImage(path: avaPath as! String, showIn: avaImageView, orShow: "user.png")
        
    }
    
    //whenever textview changes
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
    }
    
    @IBAction func addPicture_clicked(_ sender: Any) {
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
        
        
        //add buttons to the sheet
        sheet.addAction(camera)
        sheet.addAction(library)
        sheet.addAction(cancel)
        
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
    
    //executed whenever the image has been via pickcontroller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //get the selected image
        let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        pictureImageView.image = image
        
        isPictureSelected = true
        
        dismiss(animated: true, completion: nil)
    }
    
    // button share clicked
    @IBAction func shareButton_clicked(_ sender: Any) {
        
        guard let id = currentUser?["id"], let text = postTextView.text else {
            return
        }
        
        //declaring keys and values to be sent to the server
        let params = ["user_id" : id, "text" : text]
        
        let url = URL(string: "http://" + serverIP + "/fb/uploadPost.php")!
        var request = URLRequest(url: url);
        request.httpMethod = "POST";
        
        //web development and MIME Type of passing information
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var imageData = Data()
        
        // if there is picture to be posted
        if isPictureSelected {
            //convert image to data
            imageData = pictureImageView.image!.jpegData(compressionQuality: 0.5)!
        }
        
        //building the full body
        request.httpBody = Helper().body(with: params, filename: "\(NSUUID().uuidString).jpg", filePathKey: "file", imageDataKey: imageData, boundary: boundary) as Data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, showIn: self)
                    return
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
                        
                        //post notification in order to update HomeVC
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePost"), object: nil)
                        
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        Helper().showAlert(title: "Error", message: parsedJSON["message"] as! String, showIn: self )
                        return
                    }
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                }
                
            }
        }.resume()
        
    }
    
    
    
    @IBAction func cancelButton_clicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //when picture imageview tapped
    @IBAction func picuteImageView_tapped(_ sender: Any) {
        // declaring action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // declaring delete button
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.pictureImageView.image = UIImage()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        //add buttons to the sheet
        sheet.addAction(delete)
        sheet.addAction(cancel)
        
        // present action sheet to the user finally
        self.present(sheet, animated: true, completion: nil)
    }
    
    // hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //self.view.endEditing(true)
        postTextView.resignFirstResponder()
    }
}
