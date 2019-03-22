//
//  CommentsVC.swift
//  Facebook
//
//  Created by David on 1/17/19.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

class CommentsVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    //ui bar obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //post bar obj
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    //var will store data paased from previous vc
    var textString = String()
    var pictureImage = UIImage()
    
    //messaging obj
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentTextView_bottom: NSLayoutConstraint!
    @IBOutlet weak var commentTextView_height: NSLayoutConstraint!
    var commentsTextView_bottom_identity = CGFloat()
    //
    //var userInfo = NSDictionary()
    
    //comment obj
    var post_id = Int()
    
    @IBOutlet weak var tableView: UITableView!
    var avas = [UIImage]()
    var avasURL = [String]()
    var fullnames = [String]()
    var comments = [String]()
    var ids = [Int]()
    var users_ids = [Int]()
    
    var limit = 10
    var skip = 0
    
    //var will store data passed from the previous VC
    var avaImage = UIImage()
    var fullnameString = String()
    var dateString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //from previous vc
        avaImageView.image = avaImage
        fullNameLabel.text = fullnameString
        dateLabel.text = dateString
        
        textLabel.text = textString
        pictureImageView.image = pictureImage
        
        //resize no pic view
        if pictureImage.size.width == 0 {
            pictureImageView.removeFromSuperview()
            containerView.frame.size.height -= pictureImageView.frame.height
        }
        
        let formatterGet = DateFormatter()
        //get the date
        formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatterGet.date(from: dateString)!
        
        //put the date (change format)
        let formatterShow = DateFormatter()
        formatterShow.dateFormat = "MMMM dd yyyy - HH:mm"
        dateLabel.text = formatterShow.string(from: date)
        
        //rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
        
        commentTextView.layer.cornerRadius = 10
        
        //cash the textView position
        commentsTextView_bottom_identity = commentTextView_bottom.constant
        
        
        //add notification observation
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 76
        
        //run
        loadComments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //delete notification
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //keyboard will show
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboard_size = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print(commentTextView_bottom.constant)
            print(keyboard_size.height)
            commentTextView_bottom.constant = keyboard_size.height - 77
        }
        //updating the layout
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        commentTextView_bottom.constant = commentsTextView_bottom_identity
        //updating the layout
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    //send button pressed
    @IBAction func sendButton_clicked(_ sender: Any) {
        if commentTextView.text.isEmpty == false && commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            insertComment()
            commentTextView.resignFirstResponder()
        }
    }
    
    //return number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    //aasign data to the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //accessing the cell of the tableView
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentsCell
        
        //cell.avaImageView.image = avas[indexPath.row]
        cell.fullNameLAbel.text = fullnames[indexPath.row]
        cell.commentLabel.text = comments[indexPath.row]
        
        //loading and caching avas
        let avaString = avasURL[indexPath.row]
        let avaURL = URL(string: avaString)!
        if comments.count != avas.count {
            
            URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                if error != nil {
                    let image = UIImage(named: "user.png")!
                    self.avas.append(image)
                    DispatchQueue.main.async {
                        cell.avaImageView.image = image
                    }
                    return
                }
                
                if let image = UIImage(data: data!) {
                    self.avas.append(image)
                    DispatchQueue.main.async {
                        cell.avaImageView.image = image
                    }
                }
                
            }.resume()
        //all avas have been loaded
        } else {
            cell.avaImageView.image = avas[indexPath.row]
        }
        
        return cell
    }
    
    //allow to edit cell
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let currenUserID_String = currentUser?["id"] as! String
        let currentUserID_Int = Int(currenUserID_String)
        let commentatorID = users_ids[indexPath.row]
        
        if commentatorID == currentUserID_Int {
            return true
        } else {
            return false
        }
        
    }
    //deleting cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            deleteComments(indexPath: indexPath)
            
        }
        
    }
    
    
    // send http request to insert comment
    func insertComment() {
        
        //validating vars before sending
        guard let user_id = currentUser?["id"] as? String, let ava = currentUser_ava, let avaPath = currentUser?["ava"] else {
            
            if let url = URL(string: currentUser?["ava"] as! String) {
                guard let data = try? Data(contentsOf: url) else {
                    return
                }
                
                //coverting download data to the image
                guard let image = UIImage(data: data) else {
                    return
                }
                
                //assigning image to the imageView
                currentUser_ava = image
            }
            
            return
        }
        

        
        //refresh UI, add new comment in the front end
        let firstName = (currentUser?["firstName"] as! String).capitalized
        let lastName = (currentUser?["lastName"] as! String).capitalized
        let fullname = firstName + " " + lastName
        let user_id_Int = Int(user_id)!
        let comment = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //inser new comment into front-end array
        //avas.insert(currentUser_ava!, at: comments.count)
        avas.append(ava)
        fullnames.append(fullname)
        comments.append(comment)
        avasURL.append(avaPath as! String)
        users_ids.append(user_id_Int)
        
        //update tableView
        let indexPath = IndexPath(row: comments.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        //scroll to bottom
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        //empty textview
        commentTextView.text = ""
        textViewDidChange(commentTextView )
        
        let url = URL(string: "http://\(serverIP)/fb/comments.php")!
        let body = "post_id=\(post_id)&user_id=\(user_id)&action=insert&comment=\(comment)"
        print(body)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        //send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, showIn: self)
                    return
                }
                
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                    
                    guard let parsedJSON = json else {
                        return
                    }
                    
                    //if success
                    if parsedJSON["status"] as! String == "200" {
                        
                        let new_comment_id = parsedJSON["new_comment_id"] as! Int
                        self.ids.append(new_comment_id)
                        
                    } else {
                        Helper().showAlert(title: "400", message: parsedJSON["message"] as! String, showIn: self)
                        return
                    }
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                    return
                }
            }
        }.resume()
        
    }

    func loadComments() {
        
        let url = URL(string: "http://\(serverIP)/fb/comments.php")!
        let body = "action=select&post_id=\(post_id)&limit=\(limit)&offset=\(skip)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
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
                    
                    guard let parsedJSON = json?["comments"] as? [NSDictionary] else {
                        return
                    }
//                    print("==============Comments===========")
//                    print(parsedJSON)
                    
                    //every obj in comments
                    for everyComment in parsedJSON {
                        let firstName = everyComment["firstName"] as! String
                        let lastName = everyComment["lastName"] as! String
                        let fullname = firstName.capitalized + " " + lastName.capitalized
                        
                        self.fullnames.append(fullname)
                        self.comments.append(everyComment["comment"] as! String)
                        self.avasURL.append(everyComment["ava"] as! String)
                        self.ids.append(everyComment["id"] as! Int)
                        self.users_ids.append(everyComment["user_id"] as! Int)
                        
                    }
                    
                    self.tableView.reloadData()
                    
                    //scroll to the latest index
                    let indexPath = IndexPath(row: self.comments.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                    return
                }
            }
        }.resume()
        
    }
    
    //deleting cell and comment from DB
    func deleteComments(indexPath: IndexPath) {
        
        let id = ids[indexPath.row]
        let url = URL(string: "http://\(serverIP)/fb/comments.php")!
        let body = "id=\(id)&action=delete"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        //remove the cell from the front-end
        //clean up the arrays
        avas.remove(at: indexPath.row)
        avasURL.remove(at: indexPath.row)
        fullnames.remove(at: indexPath.row)
        comments.remove(at: indexPath.row)
        ids.remove(at: indexPath.row)
        users_ids.remove(at: indexPath.row)
        
        //remove cell in UI
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
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
                    
                    print(json)
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                    return
                }
            }
        }.resume()
        
    }

    @IBAction func bakcButton_clicked(_ sender: Any) {
        //come back to previous vc with show segue
        navigationController?.popViewController(animated: true)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let new_size = textView.sizeThatFits(CGSize.init(width: textView.frame.width, height: CGFloat(MAXFLOAT)))
        textView.frame.size = CGSize.init(width: CGFloat(fmaxf(Float(new_size.width), Float(textView.frame.width))), height: new_size.height)
        
        self.commentTextView_height.constant = new_size.height
        
        //UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        //}
    }
    // hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //self.view.endEditing(true)
        commentTextView.resignFirstResponder()
    }
    
}
