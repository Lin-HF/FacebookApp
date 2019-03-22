//
//  Helper.swift
//  Facebook
//
//  Created by David on 2018/11/20.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit

class Helper {
    
    var facebookColor = UIColor(red: 65/255, green: 89/255, blue: 147/255, alpha: 1)
    // validate email
    func isValid(email: String) -> Bool {
        
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: email)
        
        return result
    }
    
    // validate name
    func isValid(name: String) -> Bool {
        
        let regex = "[A-Za-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: name)
        
        return result
    }
    
    // show alert message
    func showAlert(title: String, message: String, showIn: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        showIn.present(alert, animated: true, completion: nil)
    }
    
    // allow us to go anther ViewController programmatically
    func instantiateViewController(identifier: String, animated: Bool, by vc: UIViewController, completion:(() -> Void)?)  {
        //accessing any ViewController from Main.storyboard via ID
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        // present accessed ViewController
        vc.present(newViewController, animated: animated, completion: completion)
        
    }
    
    //MIME for the Image
    func body(with parameters:[String: Any]?, filename: String, filePathKey: String?, imageDataKey: Data, boundary: String) -> NSData {
        
        let body = NSMutableData()
        
        // MIME Type for parameters [id: 777, name:michael]
        if parameters != nil {
            for (key, value) in parameters! {
                body.append(Data("--\(boundary)\r\n".utf8))
                body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
                body.append(Data("\(value)\r\n".utf8))
            }
        }
        
        //MIME Type for Image
        let mimetype = "image/jpg"
        
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimetype)\r\n\r\n".utf8))
        body.append(imageDataKey)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)--\r\n".utf8))
        return body
    }
    
    //download image from certain url
    func downloadImage(path: String, showIn imageView: UIImageView, orShow placeholder: String) {
        // if avaPath is not empty, it's blank if not assigned in DB
        if String(describing: path).isEmpty == false {
            
            DispatchQueue.main.async {
                if let url = URL(string: path) {
                    guard let data = try? Data(contentsOf: url) else {
                        imageView.image = UIImage(named: placeholder)
                        return
                    }
                    
                    //coverting download data to the image
                    guard let image = UIImage(data: data) else {
                        imageView.image = UIImage(named: placeholder)
                        return
                    }
                    
                    //assigning image to the imageView
                    imageView.image = image
                }
            }
        }
    }
    
    // load fullname
    func loadFullName(firstName: String, lastName: String, showIn label: UILabel) {
        DispatchQueue.main.async {
            label.text = "\(firstName.capitalized) \(lastName.capitalized)"
        }
    }
    
    func sendHTTPRequest(url: String, body: String, success: @escaping () -> Void, failure: @escaping () -> Void) -> NSDictionary {
    
        var result = NSDictionary()
        
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
    
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                if error != nil {
                    failure()
                    return
                }
                
                do {
                    
                    guard let data = data else {
                        failure()
                        return
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    guard let parsedJSON = json else {
                        failure()
                        return
                    }
                    
                    if parsedJSON["status"] as! String == "200" {
                        success()
                    } else {
                        failure()
                    }
                    
                    result = parsedJSON
                    
                } catch {
                    failure()
                    return
                }
            }
            
        }.resume()
    
        return result
    }
    
}
