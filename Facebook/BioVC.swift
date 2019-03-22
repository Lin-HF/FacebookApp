//
//  BioVC.swift
//  Facebook
//
//  Created by David on 1/4/19.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

class BioVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure_avaImage()
        loadUser()
    }
    
    func configure_avaImage() {
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
    }
    
    //loads all user information
    func loadUser() {
        
        // safe method of accessing user related information in glob var
        guard let firstName = currentUser?["firstName"],
            let lastName = currentUser?["lastName"],
            let avaPath = currentUser?["ava"]
            else {
                return
        }
        fullNameLabel.text = "\((firstName as! String).capitalized) \((lastName as! String).capitalized)" //"Bob Michael"
        
        // download the images and assigning to certian imageViews
        //        downloadImage(path: avaPath as! String, showIn: avaImageView)
        //        downloadImage(path: coverPath as! String, showIn: coverImageView)
        Helper().downloadImage(path: avaPath as! String, showIn: self.avaImageView, orShow: "user.png")
        
    }

    
    //1st whenever textview is about to be changed
    //True -> change False->not change
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return false
        }
        return textView.text.count + (text.count - range.length) <= 101
    }
    
    //2nd
    // excuted whenever we start typing
    func textViewDidChange(_ textView: UITextView) {
        //calculation of characters
        let allowed = 101
        let typed = textView.text.count
        let remaining = allowed - typed
        
        counterLabel.text = "\(remaining)/101"
        
        if textView.text.isEmpty {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
    }
    //save button
    @IBAction func saveButton_clicked(_ sender: Any) {
        //After removing space and lines = characters left is not empty
        if !bioTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            updateBio()
        }
    }
    //updating bio to server
    func updateBio() {
        //STEP 1. Access var/params to be sent to the server
        guard let id = currentUser?["id"], let bio = bioTextView.text else {
            return
        }
        
        //STEP 2. Declare URL, Request, Method
        let url = URL(string: "http://" + serverIP + "/fb/updateBio.php")!
        let body = "id=\(id)&bio=\(bio)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        //STEP 3. Execute and launch request
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
                    
                    //save method of casting json
                    guard let parsedJSON = json else {
                        return
                    }
                    
                    if parsedJSON["status"] as! String == "200" {
                        
                        //save updated user information
                        currentUser = parsedJSON.mutableCopy() as? NSMutableDictionary
                        UserDefaults.standard.set(currentUser, forKey: "currentUser")
                        UserDefaults.standard.synchronize()
                        
                        //Post notification
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateBio"), object: nil)
                        //dismiss
                        self.dismiss(animated: true, completion: nil)
                    // error while updating
                    } else {
                        Helper().showAlert(title: "400", message: "Error while updating the bio", showIn: self)
                    }
 
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                }
                
            }
        }.resume()
        
    }
    
    //cancel
    @IBAction func cancelButton_clicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
