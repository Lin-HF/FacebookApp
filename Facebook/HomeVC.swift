//
//  HomeVC.swift
//  Facebook
//
//  Created by David on 12/30/18.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit

class HomeVC: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //ui obj
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var addBioButton: UIButton!
    @IBOutlet weak var bioLabel: UILabel!
    
    //code obj - to distinguish
    var isCover = false
    var isAva = false
    var imageViewTapped = ""
    
    //posts obj
    var posts = [NSDictionary?]()
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var skip = 0 //offset
    var limit = 10
    var isLoading = false
    var liked = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(currentUser)
        
        //add observers notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: Notification.Name(rawValue: "updateBio"), object: nil)
        
        //add observers notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: Notification.Name(rawValue: "updateUser"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadNewPosts), name: Notification.Name(rawValue: "updatePost"), object: nil)
        
        configure_avaImageView()
        loadUser()
        loadPosts(offset: skip, limit: limit)
        print("skip:\(skip), limit\(limit)")
    }
    
    @objc func loadNewPosts() {
        print("Load more posts!")
        loadPosts(offset: 0, limit: skip + 1)
        print("limit:\(skip+1)")
    }
    
    //loads all user information
    @objc func loadUser() {
        
        // safe method of accessing user related information in glob var
        guard let firstName = currentUser?["firstName"],
              let lastName = currentUser?["lastName"],
              let avaPath = currentUser?["ava"],
              let coverPath = currentUser?["cover"],
              let bio = currentUser?["bio"]
        else {
            return
        }
        
        //check if there is ava and cover
        if (avaPath as! String).count > 10 {
            isAva = true
        } else {
            avaImageView.image = UIImage(named: "user.png")
            //refresh user profile
            currentUser_ava = self.avaImageView.image
            isAva = false
        }
        if (coverPath as! String).count > 10 {
            isCover = true
        } else {
            coverImageView.image = UIImage(named: "HomeCover.jpg")
            isCover = false
        }
        
        
        
        fullNameLabel.text = "\((firstName as! String).capitalized) \((lastName as! String).capitalized)" //"Bob Michael"
        
        // download the images and assigning to certian imageViews
//        downloadImage(path: avaPath as! String, showIn: avaImageView)
//        downloadImage(path: coverPath as! String, showIn: coverImageView)
        Helper().downloadImage(path: avaPath as! String, showIn: self.avaImageView, orShow: "user.png")
        Helper().downloadImage(path: coverPath as! String, showIn: self.coverImageView, orShow: "HomeCover.jpg")
        if (bio as! String).isEmpty {
            bioLabel.isHidden = true
            addBioButton.isHidden = false
        } else {
            bioLabel.text = "\(bio)"
            bioLabel.isHidden = false
            addBioButton.isHidden = true
        }
        
        //save the AVA image
        DispatchQueue.main.async {
            currentUser_ava = self.avaImageView.image
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
    
    func showPicker(with source:UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
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
                
                //refresh user profile
                currentUser_ava = self.avaImageView.image
                self.isAva = false
                //self.uploadImage(from: self.avaImageView)
            } else if self.imageViewTapped == "cover" {
                self.coverImageView.image = UIImage(named: "HomeCover.jpg")
                self.isCover = false
                //self.uploadImage(from: self.coverImageView)
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

    //excuted once the picture is selected in PickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        // based on the trigger cover or ava to change picture
        if imageViewTapped == "cover" {
            //aasign selected image to CoverImageView
            self.coverImageView.image = image
            //upload image to the server
            self.uploadImage(from: self.coverImageView)
        } else if imageViewTapped == "ava" {
            //assign selected image to avaImageView
            self.avaImageView.image = image
            //refresh user profile
            currentUser_ava = self.avaImageView.image
            //upload image to the server
            self.uploadImage(from: self.avaImageView)
        }
        
        // completion handler
        dismiss(animated: true) {
            if self.imageViewTapped == "cover" {
                self.isCover = true
            } else if self.imageViewTapped == "ava" {
                self.isAva = true
            }
        }
    }
    
    // sends request to server to upload the Image (ava/cover)
    func uploadImage(from imageView: UIImageView) {
        
        // get the id of current user
        guard let id = currentUser?["id"] else {
            return
        }
        
        // STEP 1. Declare URL
        let url = URL(string: "http://" + serverIP + "/fb/uploadImage.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // send to server $id and $type
        let params = ["id":id, "type":imageViewTapped]
        //let params = ["id":"", "type":""]
        
        //MIME boundary, Header
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Compressing image and converting image to 'Data' type
        var imageData = Data()
        
        if imageView.image != UIImage(named: "HomeCover.jpg") && imageView.image != UIImage(named: "user.png") {
            imageData = imageView.image!.jpegData(compressionQuality: 0.5)!
        }
        
        request.httpBody = Helper().body(with: params, filename: "\(imageViewTapped).jpg", filePathKey: "file", imageDataKey: imageData, boundary: boundary) as Data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, showIn: self)
                    return
                }
                // STEP 3. Recieve JSON message
                do {
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, showIn: self)
                        return
                    }
                    //fetch JSON generated by the server - php file
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    guard let parseJSON = json else {
                        return
                    }
                    
                    if parseJSON["status"] as! String == "200" {
                        
                        // saving updated information
                        currentUser = parseJSON.mutableCopy() as? NSMutableDictionary
                        UserDefaults.standard.set(currentUser, forKey: "currentUser")
                        UserDefaults.standard.synchronize()
                        
                    } else {
                        
                        if parseJSON["message"] != nil {
                            let message = parseJSON["message"] as! String
                            Helper().showAlert(title: "Error", message: message, showIn: self)
                        }
                    }
                    
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                }
            }
        }.resume()
    }
    
    //when bio label tapped
    @IBAction func bioLabel_tapped(_ sender: Any) {
        // declaring action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // declaring New bio button
        let bio = UIAlertAction(title: "New Bio", style: .default) { (action) in
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BioVC")
            
            self.present(vc, animated: true, completion: nil)
            
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //declaring delete Bio button
        let delete = UIAlertAction(title: "Delete Bio", style: .destructive) { (action) in
            self.deleteBio()
        }
        
        
        //add buttons to the sheet
        sheet.addAction(bio)
        sheet.addAction(cancel)
        sheet.addAction(delete)
        
        // present action sheet to the user finally
        self.present(sheet, animated: true, completion: nil)
    }
    
    //deleting bio to server
    func deleteBio() {
        //STEP 1. Access var/params to be sent to the server
        guard let id = currentUser?["id"] else {
            return
        }
        let bio = ""
        
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
                        
                        //reload user
                        self.loadUser()
                        //dismiss
                        
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
    
    //number of posts
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("一共有\(posts.count)的posts")
        return posts.count
    }
    
    //cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get picture url
        let pictureURL = posts[indexPath.row]!["picture"] as! String
        
        //no picture post
        if pictureURL.isEmpty {
            
            //accessing the cell from storyboard
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoPicCell", for: indexPath) as! NoPicCell
            
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
            let avaURL = URL(string: avaString)!
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
                        //print("Ava loaded")
                        DispatchQueue.main.async {
                            cell.avaImageView.image = image
                        }
                    }
                }.resume()
            //cached ava
            } else {
                DispatchQueue.main.async {
                    //print("AVA cached")
                    cell.avaImageView.image = self.avas[indexPath.row]
                }
            }
            pictures.append(UIImage())
            
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
        //picture post
        } else {
            
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
            let avaURL = URL(string: avaString)!
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
            
            //ava logic
            let picString = posts[indexPath.row]!["picture"] as! String
            let picURL = URL(string: picString)!
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
        
    }
    
    //loading posts from server
    func loadPosts(offset: Int, limit: Int) {
        isLoading = true
        
        //accessing id of the user
        guard let id = currentUser?["id"] else {
            return
        }
        
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
    
    //loading posts from server
    func loadMore(offset: Int, limit: Int) {
//        if (posts.count < limit) {
//            return
//        }
        isLoading = true
        //accessing id of the user
        guard let id = currentUser?["id"] else {
            return
        }
        
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
    
    //excuted whenver new cell is displayed
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //print(1)
        //get picture url
        let pictureURL = posts[indexPath.row]!["picture"] as! String
        
        //no picture post
        if pictureURL.isEmpty {
            
            //accessing the cell from storyboard
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoPicCell", for: indexPath) as! NoPicCell
            
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
            let avaURL = URL(string: avaString)!
            if posts.count != avas.count {
                URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            self.avas.append(image)
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                        }
                        //return
                    }
                    
                    if let image = UIImage(data: data!) {
                        self.avas.append(image)
                        DispatchQueue.main.async {
                            cell.avaImageView.image = image
                        }
                    }
                    }.resume()
                //cached ava
            } else {
                DispatchQueue.main.async {
                    cell.avaImageView.image = self.avas[indexPath.row]
                }
            }
            pictures.append(UIImage())
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
            
            //picture post
        } else {
            
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
            let avaURL = URL(string: avaString)!
            if posts.count != avas.count {
                URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            self.avas.append(image)
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                        }
                        //return
                    }
                    
                    if let image = UIImage(data: data!) {
                        self.avas.append(image)
                        DispatchQueue.main.async {
                            cell.avaImageView.image = image
                        }
                    }
                    }.resume()
                //cached ava
            } else {
                DispatchQueue.main.async {
                    cell.avaImageView.image = self.avas[indexPath.row]
                }
            }
            
            //ava logic
            let picString = posts[indexPath.row]!["picture"] as! String
            let picURL = URL(string: picString)!
            if posts.count != pictures.count {
                URLSession(configuration: .default).dataTask(with: picURL) { (data, response, error) in
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            self.pictures.append(image)
                            DispatchQueue.main.async {
                                cell.pictureImageView.image = image
                                //print("pic error")
                            }
                        }
                        //return
                    }
                    
                    if let image = UIImage(data: data!) {
                        self.pictures.append(image)
                        DispatchQueue.main.async {
                            cell.pictureImageView.image = image
                            //print("Pic download")
                        }
                    }
                }.resume()
                //cached ava
            } else {
                DispatchQueue.main.async {
                    cell.pictureImageView.image = self.pictures[indexPath.row]
                    //print("Pic loaded")
                }
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
        }
    }
    
    //execute whenever tableView is scrolling
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y - tableView.contentSize.height + 60 > -tableView.frame.height && isLoading == false {
            loadMore(offset: skip, limit: limit)
        }
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
            
            let vc = segue.destination as! CommentsVC
            
            vc.avaImage = avaImageView.image!
            vc.fullnameString = fullNameLabel.text!
            vc.dateString = posts[indexPathRow]!["date_created"] as! String
            
            vc.textString = posts[indexPathRow]!["text"] as! String
            
            //sending id of the post
            vc.post_id = posts[indexPathRow]!["id"] as! Int
            print("\(vc.post_id)")
            

            
            
            let indexPath = IndexPath(item: indexPathRow, section: 0)
            guard let cell = tableView.cellForRow(at: indexPath) as? PicCell else {
                return
            }

            vc.pictureImage = cell.pictureImageView.image!
        }
    }
    
    // Options Button
    @IBAction func optionsButton_clicked(_ optionButton: UIButton) {
        
        let indexPathRow = optionButton.tag
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let delete = UIAlertAction(title: "Delte Post", style: .destructive) { (delete) in
            self.deletePost(indexPathRow)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    //send delete request to the server
    func deletePost(_ row: Int) {
        
        guard let id = posts[row]?["id"] as? Int else {
            return
        }
        
        let url = URL(string: "http://\(serverIP)/fb/deletePost.php")!
        let body = "id=\(id)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        //remove the cell
        posts.remove(at: row)
        avas.remove(at: row)
        pictures.remove(at: row)
        liked.remove(at: row)
        
        let indexPath = IndexPath(row: row, section: 0)
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
    
    @IBAction func moreButton_clicked(_ sender: Any) {
        
        //creating action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let logout = UIAlertAction(title: "Log out", style: .destructive) { (action) in
            let loginvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            
            //show login view controller
            self.present(loginvc, animated: true, completion:  {
                
                //clean
                currentUser = NSMutableDictionary()
                UserDefaults.standard.set(currentUser, forKey: "currentUser")
                UserDefaults.standard.synchronize() // save
                
                
            })
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //add button
        sheet.addAction(logout)
        sheet.addAction(cancel)
        
        present(sheet, animated: true, completion: nil)
    }
    
}
