//
//  GuestVC.swift
//  Facebook
//
//  Created by David on 1/25/19.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

class GuestVC: UITableViewController {

    //button obj
    @IBOutlet weak var friendButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    //ui obj
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    //vars to catch received data
    var id = Int()
    var firstName = String()
    var lastName = String()
    var avaPath = String()
    var coverPath = String()
    var bio = String()
    var allow_friends = Int()
    var allow_follow = Int()
    var isFollowed = Int()
    
    //post obj
    var posts = [NSDictionary?]()
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var liked = [Int]()
    var skip = 0
    var limit = 10
    var isLoading = false
    //colors
    let likeColor = UIColor(red: 28/255, green: 165/255, blue: 252/255, alpha: 1)
    
    //trigger to check if is requested
    var friendshipStatus = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //apply extension property to buttons
        friendButton.centerVertically()
        followButton.centerVertically()
        messageButton.centerVertically()
        moreButton.centerVertically()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 440.67
        
        configure_avaImageView()
        loadUser()
        loadPosts(offset: skip, limit: limit)

    }
    // load all information
    func loadUser() {
        
        //ava placeholder
        if avaPath.count < 10 {
            avaImageView.image = UIImage(named: "user.png")
        } else {
            Helper().downloadImage(path: avaPath, showIn: avaImageView, orShow: "user.png")
        }
        
        if coverPath.count < 10 {
            coverImageView.image = UIImage(named: "HomeCover.jpg")
        } else {
            Helper().downloadImage(path: coverPath, showIn: coverImageView, orShow: "HomeCover.jpg")
        }
        
        if allow_friends == 0 {
            friendButton.isEnabled = false
        }
        
        if allow_follow == 0 {
            followButton.isEnabled = false
        }
        
        //if guest user is followed
        if isFollowed != Int() {
            update(button: followButton, icon: "follow.png", title: "Following", color: Helper().facebookColor)
            followButton.isEnabled = true
        }
        
        fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
        
        //bio check - no bio condition
        bioLabel.text = bio
        if bio.isEmpty {
            headerView.frame.size.height -= 30
        }
        
        //apperance of addFriend button
        if friendshipStatus == 0 {
            
            update(button: friendButton, icon: "unfriend.png", title: "Add", color: .darkGray)

        } else if friendshipStatus == 1{
            
            update(button: friendButton, icon: "request.png", title: "Requested", color: Helper().facebookColor)
        
        //user requested current user to be friend
        } else if friendshipStatus == 2 {
            
            update(button: friendButton, icon: "respond.png", title: "Respond", color: Helper().facebookColor)
            
        //they are friends
        } else if friendshipStatus == 3 {
            
            update(button: friendButton, icon: "friends.png", title: "Friends", color: Helper().facebookColor)
            
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //accessing the cell from storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "PicCell", for: indexPath) as! PicCell
        
        let firstName = posts[indexPath.row]!["firstName"] as! String
        let lastName = posts[indexPath.row]!["lastName"] as! String
        cell.fullNameLabel.text = firstName.capitalized + " " + lastName.capitalized
        
        //date logic
        let dateString = posts[indexPath.row]!["date_created"] as! String
        let formatterGet = DateFormatter()
        //get the date
        formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatterGet.date(from: dateString)!
        
        //put the date (change format)
        let formatterShow = DateFormatter()
        formatterShow.dateFormat = "MMMM dd yyyy - HH:mm"
        cell.dateLabel.text = formatterShow.string(from: date)
        
        let text = posts[indexPath.row]!["text"] as! String
        cell.postTextLabel.text = text
        
        //ava logic
        let avaString = posts[indexPath.row]!["ava"] as! String
        if let avaURL = URL(string: avaString) {
            if posts.count != avas.count {
                URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            self.avas.append(image)
                            //print("AVA assigned")
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                        }
                        //return
                    }
                    
                    if let image = UIImage(data: data!) {
                        self.avas.append(image)
                        //print("AVA loaded")
                        DispatchQueue.main.async {
                            cell.avaImageView.image = image
                        }
                    }
                    }.resume()
                //cached ava
            } else {
                //print("AVA cached")
                DispatchQueue.main.async {
                    cell.avaImageView.image = self.avas[indexPath.row]
                }
            }
            
        } else {
            
            //append array pf avas with placeholder image
            let placeholderImage = UIImage(named: "user.png")
            self.avas.append(placeholderImage!)
        }
        
        //ava logic
        let picString = posts[indexPath.row]!["picture"] as! String
        if let picURL = URL(string: picString) {
            if posts.count != pictures.count {
                URLSession(configuration: .default).dataTask(with: picURL) { (data, response, error) in
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            self.pictures.append(image)
                            //print("Pic assigned")
                            DispatchQueue.main.async {
                                cell.pictureImageView.image = image
                                //print("pic error")
                            }
                        }
                        //return
                    }
                    
                    if let image = UIImage(data: data!) {
                        self.pictures.append(image)
                        //print("PIC loaded")
                        DispatchQueue.main.async {
                            cell.pictureImageView.image = image
                            //print("Pic download")
                        }
                    }
                    }.resume()
                //cached ava
            } else {
                //print("Pic cached")
                DispatchQueue.main.async {
                    cell.pictureImageView.image = self.pictures[indexPath.row]
                    
                }
            }
        } else {
            self.pictures.append(UIImage())
            
            //resize cell
            cell.pictureImageView_height.constant = 0
            cell.updateConstraints()
        }
        //get the index of the cell
        cell.likeButton.tag = indexPath.row
        cell.commentsButton.tag = indexPath.row
        cell.optionsButton.tag = indexPath.row
        
        //check if the post is liked
        DispatchQueue.main.async {
            if self.liked[indexPath.row] == 1 {
                cell.likeButton.setImage(UIImage(named: "like.png"), for: .normal)
                cell.likeButton.tintColor = UIColor(red: 59/255, green: 87/255, blue: 157/255, alpha: 1)
            } else {
                cell.likeButton.setImage(UIImage(named: "unlike.png"), for: .normal)
                cell.likeButton.tintColor = UIColor.darkGray
            }
        }
        return cell
    }
    
    //loading posts from server
    func loadPosts(offset: Int, limit: Int) {
        isLoading = true
        
        //prepare request
        let url = URL(string: "http://\(serverIP)/fb/selectPosts.php")!
        let body = "id=\(id)&offset=\(offset)&limit=\(limit)"
        print(body)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        //send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            //run in background
            DispatchQueue.main.async {
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, showIn: self)
                    return
                }
                
                do {
                    //access data
                    guard let data = data else {
                        return
                    }
                    
                    //receiving data to json
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    print("Loading========================================")
                    //print(json)
                    
                    guard let posts = json?["posts"] as? [NSDictionary] else {
                        return
                    }
                    //print(posts)
                    print(posts.count)
                    print(self.posts.count)
                    //load posts
                    self.posts = posts
                    
                    //read next new posts
                    self.skip = posts.count
                    
                    //clean up
                    self.liked.removeAll(keepingCapacity: false)
                    
                    //tracking liked posts
                    for post in posts {
                        if post["liked"] is NSNull {
                            self.liked.append(Int())
                        } else {
                            self.liked.append(1)
                        }
                    }
                    
                    self.tableView.reloadData()
                    self.isLoading = false
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                    return
                }
            }
            
            }.resume()
        
    }
    
    //execute whenever tableView is scrolling
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y - tableView.contentSize.height + 60 > -tableView.frame.height && isLoading == false {
            loadMore(offset: skip, limit: limit)
        }
    }
    
    //loading posts from server
    func loadMore(offset: Int, limit: Int) {
        //        if (posts.count < limit) {
        //            return
        //        }
        isLoading = true

        
        //print("posts.count = \(posts.count), offset = \(offset), limit = \(limit)")
        //prepare request
        let url = URL(string: "http://\(serverIP)/fb/selectPosts.php")!
        let body = "id=\(id)&offset=\(offset)&limit=\(limit)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        //send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            //run in background
            DispatchQueue.main.async {
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, showIn: self)
                    self.isLoading = false
                    return
                }
                
                do {
                    //access data
                    guard let data = data else {
                        self.isLoading = false
                        return
                    }
                    
                    //receiving data to json
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    
                    guard let newPosts = json?["posts"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    print(newPosts)
                    
                    //load posts
                    self.posts.append(contentsOf: newPosts)
                    
                    //read next new posts
                    self.skip += newPosts.count
                    
                    //tracking liked posts
                    for post in newPosts {
                        if post["liked"] is NSNull {
                            self.liked.append(Int())
                        } else {
                            self.liked.append(1)
                        }
                    }
                    
                    self.tableView.beginUpdates()
                    
                    for i in 0 ..< newPosts.count {
                        let lastSectionIndex = self.tableView.numberOfSections - 1
                        let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex)
                        let pathToLastRow = IndexPath(row: lastRowIndex + i, section: lastSectionIndex)
                        self.tableView.insertRows(at: [pathToLastRow], with: .fade)
                    }
                    
                    self.tableView.endUpdates()
                    self.isLoading = false
                    
                } catch {
                    self.isLoading = false
                    return
                }
            }
            
            }.resume()
        
    }

    
    //Like button clicked
    @IBAction func likeButton_clicked(_ likeButton: UIButton) {
        
        //        //change the like icon
        //        likeButton.setImage(UIImage(named: "like.png"), for: .normal)
        
        //get index
        let indexPathRow = likeButton.tag
        //user id
        guard let user_id = currentUser?["id"] else {
            return
        }
        //post id
        guard let post_id = posts[indexPathRow]!["id"] else {
            return
        }
        
        // Logic for like and unlike
        var action = ""
        if liked[indexPathRow] == 1 {
            action = "delete"
            //kkep in front-end that this post has been liked
            //liked.insert(Int(), at: indexPathRow)
            liked[indexPathRow] = Int()
            //change the like icon
            likeButton.setImage(UIImage(named: "unlike.png"), for: .normal)
            likeButton.tintColor = UIColor.darkGray
            
        } else {
            action = "insert"
            //kkep in front-end that this post has been liked
            //liked.insert(1, at: indexPathRow)
            liked[indexPathRow] = 1
            //change the like icon
            likeButton.setImage(UIImage(named: "like.png"), for: .normal)
            likeButton.tintColor = UIColor(red: 59/255, green: 87/255, blue: 157/255, alpha: 1)
        }
        
        //animation for zooming / poping
        UIView.animate(withDuration: 0.15, animations: {
            likeButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
        }) { (completed) in
            //return to initial state
            UIView.animate(withDuration: 0.15, animations: {
                likeButton.transform = CGAffineTransform.identity
            })
        }
        
        
        //prepare request
        let url = URL(string: "http://\(serverIP)/fb/like.php")!
        let body = "post_id=\(post_id)&user_id=\(user_id)&action=\(action)"
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
                    //print(json)
                    
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                    return
                }
            }
            }.resume()
    }
    
    //executed when show segue is about to be launched
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //index of the cell
        let indexPathRow = (sender as! UIButton).tag
        
        if segue.identifier == "CommentsVC" {
            
            let commentsvc = segue.destination as! CommentsVC
            
            commentsvc.avaImage = avaImageView.image!
            commentsvc.fullnameString = fullnameLabel.text!
            commentsvc.dateString = posts[indexPathRow]!["date_created"] as! String
            
            commentsvc.textString = posts[indexPathRow]!["text"] as! String
            
            //sending id of the post
            commentsvc.post_id = posts[indexPathRow]!["id"] as! Int
            print("\(commentsvc.post_id)")
            
            
            
            
            let indexPath = IndexPath(item: indexPathRow, section: 0)
            
            commentsvc.pictureImage = pictures[indexPath.row]
            
            //Hide navigation bar
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    //pre-load
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //update the buttons
    func update(button: UIButton, icon:String, title: String, color: UIColor) {
        
        //icon
        let image = UIImage(named: icon)
        button.setBackgroundImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        button.tintColor = color
        button.titleLabel?.textColor = color
        
        //animation for zooming / poping
        UIView.animate(withDuration: 0.15, animations: {
            button.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            
        }) { (completed) in
            //return to initial state
            UIView.animate(withDuration: 0.15, animations: {
                button.transform = CGAffineTransform.identity
            })
        }
    }
    
    //update the status of the request
    func updateFriendhipRequest(with action: String, user_id: Any, friend_id: Any) {
        
        let url = URL(string: "http://\(serverIP)/fb/friends.php")!
        let body = "action=\(action)&user_id=\(user_id)&friend_id=\(friend_id)"
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
                    
                    print(json)
                    
                    guard let parsedJSON =  json else {
                        return
                    }
                    
                    if parsedJSON["status"] as! String == "200" && action != "follow" && action != "unfollow" {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "friend"), object: nil)
                    }
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                    return
                }
            }
            
            }.resume()
    }
    
    
    // firend button clicked
    @IBAction func friendButton_clicked(_ friendButton: UIButton) {
        
        //accessing index path
        let indexPathRow = friendButton.tag
        
        //get the ids of current users
        guard let currenUser_id = currentUser?["id"], let friendUser_id = id as? Int else {
            return
        }
        
        //stranger
        if friendshipStatus == 0 {
            
            //update status
            friendshipStatus = 1
            
            //update button
            update(button: friendButton, icon: "request.png", title: "Requested", color: Helper().facebookColor)
            
            //send to server
            updateFriendhipRequest(with: "add", user_id: currenUser_id, friend_id: friendUser_id)
            
            //current user sent frienship -> cancel it
        } else if friendshipStatus == 1 {
            
            //update status in front end
            friendshipStatus = 0
            
            update(button: friendButton, icon: "unfriend.png", title: "Add", color: .darkGray)
            
            //send to server
            updateFriendhipRequest(with: "reject", user_id: currenUser_id, friend_id: friendUser_id)
            //current user received friendship request -> show actionsheet
        } else if friendshipStatus == 2 {
            
            //show action sheet: confirm or delete
            self.showAction(button: friendButton, friendUser_id: friendUser_id, currentUser_id: currenUser_id)
            
            //current user and searched user are friend -> action sheet delete
        } else if friendshipStatus == 3 {
            
            //show action sheet: delete
            self.showAction(button: friendButton, friendUser_id: friendUser_id, currentUser_id: currenUser_id)
        }
    }
    
    
    func showAction(button: UIButton, friendUser_id: Any, currentUser_id: Any) {
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //trigger action
        var destructiveAction = ""
        
        
        if friendshipStatus == 2 {
            destructiveAction = "reject" //be requested
        } else {
            destructiveAction = "delete" //already friend
        }
        
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            //no more relation
            self.friendshipStatus = 0
            self.update(button: button, icon: "unfriend.png", title: "Add", color: .darkGray)
            //order may different
            self.updateFriendhipRequest(with: destructiveAction, user_id: currentUser_id, friend_id: friendUser_id)
            self.updateFriendhipRequest(with: destructiveAction, user_id: friendUser_id, friend_id: currentUser_id)
        }
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            self.friendshipStatus = 3
            self.update(button: button, icon: "friends.png", title: "Friends", color: Helper().facebookColor)
            self.updateFriendhipRequest(with: "confirm", user_id: friendUser_id, friend_id: currentUser_id)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sheet.addAction(delete)
        
        if friendshipStatus == 2 {
            sheet.addAction(confirm)
        }
        
        sheet.addAction(cancel)
        
        present(sheet, animated: true, completion: nil)
        
    }
    
    //send request to server
    @IBAction func followButton_clicked(_ followButton: UIButton) {
        
        guard let currentUser_id = currentUser?["id"] else {
            return
        }
        
        let follow_id = self.id
        
        if isFollowed == Int() {
        //do follow
            
            isFollowed = 1
            
            update(button: followButton, icon: "follow.png", title: "Following", color: Helper().facebookColor)
            
            updateFriendhipRequest(with: "follow", user_id: currentUser_id, friend_id: follow_id)
            
        } else {
        // stop follow
            
            isFollowed = Int()
            
            update(button: followButton, icon: "unfollow.png", title: "Follow", color: .darkGray)
            
            updateFriendhipRequest(with: "unfollow", user_id: currentUser_id, friend_id: follow_id)
            
            
            
        }
        
    }
    
    //more button clicked
    @IBAction func moreButton_clicked(_ sender: Any) {
        showReportSheet(post_id: 0)
    }
    
    //called when options button is post cell has been clicked
    @IBAction func optionsButton_clicked(_ optionsButton: UIButton) {
        
        let indexPathRow = optionsButton.tag
        
        let post_id = posts[indexPathRow]!["id"] as! Int
        
        print(post_id)
        
        showReportSheet(post_id: post_id)
    }
    
    func showReportSheet(post_id: Int) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let report = UIAlertAction(title: "Report", style: .default) { (action) in
            let alert = UIAlertController(title: "Report", message: "Please explain the reason", preferredStyle: .alert)
            
            let report = UIAlertAction(title: "Send", style: .default) { (action) in
                
                guard let currenUser_id = currentUser?["id"] else {
                    return
                }
                
                let user_id = self.id
                
                let textField = alert.textFields![0]
                
                let url = "http:\(serverIP)/fb/report.php"
                let body = "post_id=\(post_id)&user_id=\(user_id)&reason=\(textField.text!)&byUser_id=\(currenUser_id)"
                
                //Send to server
                _ = Helper().sendHTTPRequest(url: url, body: body, success: {
                    Helper().showAlert(title: "Success", message: "Report Sent Successfully", showIn: self)
                }, failure: {
                    Helper().showAlert(title: "Error", message: "Could not sent", showIn: self)
                })
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(report)
            alert.addAction(cancel)
            alert.addTextField { (textField) in
                textField.placeholder = "I'm reporting because..."
                textField.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(report)
        sheet.addAction(cancel)
        present(sheet, animated: true, completion: nil)
    }
    
}

extension UIButton {
    
    // adjust the icon and title position
    func centerVertically() {
        
        //adjust title's width
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: -20)
        //vertical position of title
        let padding = self.frame.height + 10
        
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        
        let totalHeight = imageSize.height + titleSize.height + padding
        
        //icon
        self.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height), left: 0, bottom: 0, right: -titleSize.width)
        
        //final position of title by vertical
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(totalHeight - titleSize.height), right: 0)
        
    }
}
