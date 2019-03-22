//
//  FriendsVC.swift
//  Facebook
//
//  Created by David on 1/21/19.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

class FriendsVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, FriendRequestCellDelegate {
    
    // delegate from cell
    func updateFriendshipRequestDelegate(with action: String, status: Int, from cell: UITableViewCell) {
        
        guard let indexPath = friendsTableView.indexPath(for: cell) else {
            return
        }
        
        if action == "confirm" {
            friendshipStatus.append(3)
        } else {
            friendshipStatus.append(0)
        }
        
        guard let user_id = requestedUsers[indexPath.row]["id"], let friend_id = currentUser?["id"] else {
            return
        }
        
        updateFriendhipRequest(with: action, user_id: user_id, friend_id: friend_id)
        
    }
    

    //Part 1, search
    //ui obj
    @IBOutlet weak var searchTableView: UITableView!
    
    //searched users
    var searchBar = UISearchBar()
    var searchedUsers = [NSDictionary]()
    var searchedUsers_avas = [UIImage]()
    
    //Int
    var searchLimit = 15
    var searchSkip = 0
    var friendshipStatus = [Int]()
    var isUserFollowed = [Int]()
    
    //Part 2 Request and Friends
    var requestedUsers = [NSDictionary]()
    var requestedUsers_avas = [UIImage]()
    var requestedHeaders = ["FRIEND REQUESTS"]
    
    var requestedLimit = 10
    var requestedUsersSkip = 0
    
    //Bool
    var isLoading = false
    var isSearchedStatusUpdated = false
    
    //Part 2 Requests
    @IBOutlet weak var friendsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        searchTableView.rowHeight = UITableView.automaticDimension
//        searchTableView.estimatedRowHeight = 100
        createSearchBar()
        loadRequests()
        
        NotificationCenter.default.addObserver(self, selector: #selector(searchUsers), name: Notification.Name(rawValue: "friend"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadRequests), name: Notification.Name(rawValue: "friend"), object: nil)
    }
    

    //create search bar programatically
    func createSearchBar() {
        
        //create search bar
        
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .white
        
        let searchBar_textField = searchBar.value(forKey: "searchField") as? UITextField
        searchBar_textField?.textColor = .white
        searchBar_textField?.tintColor = .white
        
        //insert search bar into navigationBar
        self.navigationItem.titleView = searchBar
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //cancel button
        searchBar.setShowsCancelButton(true, animated: true)
        searchTableView.isHidden = false
        
    }
    
    //cancel button clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(false, animated: true)
        
        searchTableView.isHidden = true
        
        searchBar.resignFirstResponder()
        
        //remove results
        searchBar.text = ""
        searchedUsers.removeAll(keepingCapacity: false)
        searchedUsers_avas.removeAll(keepingCapacity: false)
        friendshipStatus.removeAll(keepingCapacity: false)
        searchTableView.reloadData()
    }
    
    //when user type in name
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchUsers()
    }
    
    @objc func searchUsers() {
        
        isLoading = true
        
        guard let currentUser_id = currentUser?["id"] else {
            isLoading = false
            return
        }
        
        let name = searchBar.text!
        if name.isEmpty {
            return
        }
        
        //http request
        
        let url = URL(string: "http://\(serverIP)/fb/friends.php")!
        let body = "action=search&name=\(name)&id=\(currentUser_id)&limit=\(searchLimit)&offset=0"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                if error != nil {
                    self.isLoading = false
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, showIn: self)
                    return
                }
                
                do {
                    guard let data = data else {
                        self.isLoading = false
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, showIn: self)
                        return
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary

                    print(json)
                    
                    if let status = json?["status"] as? String {
                        if status == "400" {
                            //remove results
                            self.searchedUsers.removeAll(keepingCapacity: false)
                            self.searchedUsers_avas.removeAll(keepingCapacity: false)
                            self.searchTableView.reloadData()
                        }
                    }
                    
                    guard let users = json?["users"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    
                    //save accessed JSON in array
                    self.searchedUsers = users
                    
                    //clean up the array of requested, the first time load
                    self.friendshipStatus.removeAll(keepingCapacity: false)
                    self.searchedUsers_avas.removeAll(keepingCapacity: false)
                    
                    //
//                    for user in users {
//                        if user["requested"] is NSNull {
//                            self.friendshipStatus.append(Int())
//                        } else {
//                            self.friendshipStatus.append(1)
//                        }
//                    }
                    
                    //check friendship status
                    for user in users {
                        //request sender is current user
                        if user["request_sender"] is NSNull == false && user["request_sender"] as? Int == Int(currentUser_id as! String){
                            self.friendshipStatus.append(1);
                        
                        //request received by current user
                        } else if user["request_receiver"] is NSNull == false && user["request_receiver"] as? Int == Int(currentUser_id as! String) {
                            self.friendshipStatus.append(2);
                        
                        //currenuser is the one who sent invatation friendship and got accept
                        } else if user["friendship_sender"] is NSNull == false {
                            self.friendshipStatus.append(3);
                            
                        //current user who accept the friendship
                        } else if user["friendship_receiver"] is NSNull == false {
                            self.friendshipStatus.append(3)
                        
                        //all other status
                        } else {
                            self.friendshipStatus.append(0)
                        }
                        
                    }
                    
                    //update skip
                    self.searchSkip = users.count
                    
                    //update tableView
                    self.searchTableView.reloadData()
                    
                    self.isLoading = false
                } catch {
                    self.isLoading = false
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                    return
                }
            }
            
            }.resume()
    }
    
    //execute whenever tableView is scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchTableView.contentOffset.y - searchTableView.contentSize.height + 60 > -searchTableView.frame.height && isLoading == false && searchedUsers.count >= searchLimit{
            searchMore(offset: searchSkip, limit: searchLimit)
        }
    }
    
    func searchMore(offset: Int, limit: Int) {
        isLoading = true
        
        guard let currentUser_id = currentUser?["id"] else {
            isLoading = false
            return
        }
        
        let name = searchBar.text!
        if name.isEmpty {
            return
        }
        
        //http request
        
        let url = URL(string: "http://\(serverIP)/fb/friends.php")!
        let body = "action=search&name=\(name)&id=\(currentUser_id)&limit=\(limit)&offset=\(searchSkip)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                if error != nil {
                    self.isLoading = false
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, showIn: self)
                    return
                }
                
                do {
                    guard let data = data else {
                        self.isLoading = false
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, showIn: self)
                        return
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    guard let users = json?["users"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    
                    //add new data
                    self.searchedUsers.append(contentsOf: users)
                    
                    self.searchSkip += users.count
                    
//                    //
//                    for user in users {
//                        if user["requested"] is NSNull {
//                            self.friendshipStatus.append(Int())
//                        } else {
//                            self.friendshipStatus.append(1)
//                        }
//                    }

                    //check friendship status
                    for user in users {
                        //request sender is current user
                        if user["request_sender"] is NSNull == false && user["request_sender"] as? Int == Int(currentUser_id as! String){
                            self.friendshipStatus.append(1);
                            
                            //request received by current user
                        } else if user["request_receiver"] is NSNull == false && user["request_receiver"] as? Int == Int(currentUser_id as! String) {
                            self.friendshipStatus.append(2);
                            
                            //currenuser is the one who sent invatation friendship and got accept
                        } else if user["friendship_sender"] is NSNull == false {
                            self.friendshipStatus.append(3);
                            
                            //current user who accept the friendship
                        } else if user["friendship_receiver"] is NSNull == false {
                            self.friendshipStatus.append(3)
                            
                            //all other status
                        } else {
                            self.friendshipStatus.append(0)
                        }
                    }
                    
                    self.searchTableView.beginUpdates()
                    for i in 0 ..< users.count {
                        let lastSectionIndex = self.searchTableView.numberOfSections - 1
                        let lastRowIndex = self.searchTableView.numberOfRows(inSection: lastSectionIndex)
                        let pathToLastRow = IndexPath(row: lastRowIndex + i, section: lastSectionIndex)
                        self.searchTableView.insertRows(at: [pathToLastRow], with: .fade)
                    }
                    self.searchTableView.endUpdates()
                    
                    self.isLoading = false
                    
                } catch {
                    self.isLoading = false
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                    return
                }
            }
            
            }.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView {
            return searchedUsers.count
        } else {
            return requestedUsers.count
        }
    }
    
    //height for both cells: both 100
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //section header of cells
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == friendsTableView {
            if section <= requestedHeaders.count {
                return requestedHeaders[section]
            }
        }
        return nil
    }
    
    //Font of the header
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 12)!
        header.textLabel?.textColor = UIColor.darkGray
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == searchTableView {
            
            //access cell
            let cell = searchTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchUserCell
            
            let firstName = searchedUsers[indexPath.row]["firstName"] as! String
            let lastName = searchedUsers[indexPath.row]["lastName"] as! String
            cell.fullNameLabel.text = firstName.capitalized + " " + lastName.capitalized
            cell.friendButton.tag = indexPath.row
            
            //ava logic
            let avaString = searchedUsers[indexPath.row]["ava"] as! String
            
            var avaURL = URL(string: "http://")
            if avaString.isEmpty == false {
                avaURL = URL(string: avaString)
            }
            
            
            if searchedUsers.count != searchedUsers_avas.count {
                URLSession(configuration: .default).dataTask(with: avaURL!) { (data, response, error) in
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            self.searchedUsers_avas.append(image)
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                        }
                        //return
                    }
                    
                    if let image = UIImage(data: data!) {
                        self.searchedUsers_avas.append(image)
                        DispatchQueue.main.async {
                            cell.avaImageView.image = image
                        }
                    }
                    }.resume()
                //cached ava
            } else {
                DispatchQueue.main.async {
                    cell.avaImageView.image = self.searchedUsers_avas[indexPath.row]
                }
            }
            
            //friend button
            DispatchQueue.main.async {
                
                // if user is not allowing a friendship request
                if self.searchedUsers[indexPath.row]["allow_friends"] as! Int == 0 {
                    cell.friendButton.isHidden = true
                    cell.accessoryType = .disclosureIndicator
                } else {
                    cell.friendButton.isHidden = false
                    cell.accessoryType = .none
                }
                
                //current user sent friendship request
                if self.friendshipStatus[indexPath.row] == 1 {

                    self.update(button: cell.friendButton, icon: "request.png", color: Helper().facebookColor)
                
                //currentUser received the request
                } else if self.friendshipStatus[indexPath.row] == 2 {
                    
                    self.update(button: cell.friendButton, icon: "respond.png", color: Helper().facebookColor)
                    
                //current user and user are friends
                } else if self.friendshipStatus[indexPath.row] == 3 {
                    
                    self.update(button: cell.friendButton, icon: "friends.png", color: Helper().facebookColor)
                
                // mean just strangers
                } else {
                    
                    self.update(button: cell.friendButton, icon: "unfriend.png", color: .darkGray)
                }
                
            }
            
            
            return cell
        
            //cell for request
        } else {
            //access cell
            let cell = friendsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FriendRequestCell
            
            //create the delegate
            cell.delegate = self
            
            let firstName = requestedUsers[indexPath.row]["firstName"] as! String
            let lastName = requestedUsers[indexPath.row]["lastName"] as! String
            cell.fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
            
            //ava logic
            let avaString = requestedUsers[indexPath.row]["ava"] as! String
            
            var avaURL = URL(string: "http://")
            if avaString.isEmpty == false {
                avaURL = URL(string: avaString)
            }
            
            
            if requestedUsers.count != requestedUsers_avas.count {
                URLSession(configuration: .default).dataTask(with: avaURL!) { (data, response, error) in
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            self.requestedUsers_avas.append(image)
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                        }
                        //return
                    }
                    
                    if let image = UIImage(data: data!) {
                        self.requestedUsers_avas.append(image)
                        DispatchQueue.main.async {
                            cell.avaImageView.image = image
                        }
                    }
                    }.resume()
                //cached ava
            } else {
                DispatchQueue.main.async {
                    cell.avaImageView.image = self.requestedUsers_avas[indexPath.row]
                }
            }
            return cell
            
        }
        
        
    }
    
    //update button
    func update(button: UIButton, icon: String, color: UIColor) {
        button.setBackgroundImage(UIImage(named: icon), for: .normal)
        button.tintColor = color
    }
    
//    //http to fetch users from DB
//    func searchUsers() {
//
//
//
//    }
    
    @IBAction func friendButton_clicked(_ friendButton: UIButton) {
        
        //accessing index path
        let indexPathRow = friendButton.tag
        
        //get the ids of current users
        guard let currenUser_id = currentUser?["id"], let friendUser_id = searchedUsers[indexPathRow]["id"] else {
            return
        }
        
        //stranger
        if friendshipStatus[indexPathRow] == 0 {
            
            isSearchedStatusUpdated = true
           
            //update status
            friendshipStatus[indexPathRow] = 1
            
            //update button
            update(button: friendButton, icon: "request.png", color: Helper().facebookColor)
            
            //send to server
            updateFriendhipRequest(with: "add", user_id: currenUser_id, friend_id: friendUser_id)
            
        //current user sent frienship -> cancel it
        } else if friendshipStatus[indexPathRow] == 1 {
            
            isSearchedStatusUpdated = true
            
            //update status in front end
            friendshipStatus[indexPathRow] = 0
            
            update(button: friendButton, icon: "unfriend.png", color: .darkGray)
            
            //send to server
            updateFriendhipRequest(with: "reject", user_id: currenUser_id, friend_id: friendUser_id)
        //current user received friendship request -> show actionsheet
        } else if friendshipStatus[indexPathRow] == 2 {
            
            isSearchedStatusUpdated = true
            
            //show action sheet: confirm or delete
            self.showAction(button: friendButton, friendUser_id: friendUser_id, currentUser_id: currenUser_id, indexPathRow: indexPathRow)
            
        //current user and searched user are friend -> action sheet delete
        } else if friendshipStatus[indexPathRow] == 3 {
            
            isSearchedStatusUpdated = true
            
            //show action sheet: delete
            self.showAction(button: friendButton, friendUser_id: friendUser_id, currentUser_id: currenUser_id, indexPathRow: indexPathRow)
        }
        
    }
    
    //show action sheet for friendship action
    func showAction(button: UIButton, friendUser_id: Any, currentUser_id: Any, indexPathRow: Int) {
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //trigger action
        var destructiveAction = ""
        
        
        if friendshipStatus[indexPathRow] == 2 {
            destructiveAction = "reject" //be requested
        } else {
            destructiveAction = "delete" //already friend
        }
        
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            //no more relation
            self.friendshipStatus[indexPathRow] = 0
            self.update(button: button, icon: "unfriend.png", color: .darkGray)
            //order may different
            self.updateFriendhipRequest(with: destructiveAction, user_id: currentUser_id, friend_id: friendUser_id)
            self.updateFriendhipRequest(with: destructiveAction, user_id: friendUser_id, friend_id: currentUser_id)
        }
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            self.friendshipStatus[indexPathRow] = 3
            self.update(button: button, icon: "friends.png", color: Helper().facebookColor)
            self.updateFriendhipRequest(with: "confirm", user_id: friendUser_id, friend_id: currentUser_id)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sheet.addAction(delete)
        
        if friendshipStatus[indexPathRow] == 2 {
            sheet.addAction(confirm)
        }
        
        sheet.addAction(cancel)
        
        present(sheet, animated: true, completion: nil)
        
    }
    
    
    // Confirm / Reject / send
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
                    
                    //if users' status updated from the searchTableView
                    if self.isSearchedStatusUpdated == true {
                        self.loadRequests()
                        self.isSearchedStatusUpdated = false
                    }
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                    return
                }
            }
            
            }.resume()
    }
    
    //before segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GuestVC_SearchTableView" {
            //access the index of the selected row
            guard let indexPath = searchTableView.indexPathForSelectedRow else {
                return
            }
            
            let guestvc = segue.destination as! GuestVC
            let id = searchedUsers[indexPath.row]["id"] as! Int
            let firstName = searchedUsers[indexPath.row]["firstName"] as! String
            let lastName = searchedUsers[indexPath.row]["lastName"] as! String
            let avaPath = searchedUsers[indexPath.row]["ava"] as! String
            let coverPath = searchedUsers[indexPath.row]["cover"] as! String
            let bio = searchedUsers[indexPath.row]["bio"] as! String
            let allow_friends = searchedUsers[indexPath.row]["allow_friends"] as? Int ?? Int()
            let allow_follow = searchedUsers[indexPath.row]["allow_follow"] as? Int ?? Int()
            let isFollowed = searchedUsers[indexPath.row]["followed_user"] as? Int ?? Int()
            
            guestvc.id = id
            guestvc.firstName = firstName
            guestvc.lastName = lastName
            guestvc.avaPath = avaPath
            guestvc.coverPath = coverPath
            guestvc.bio = bio
            guestvc.friendshipStatus = friendshipStatus[indexPath.row]
            guestvc.allow_friends = allow_friends
            guestvc.allow_follow = allow_follow
            guestvc.isFollowed = isFollowed
        
            //tapped on a friend
        } else if segue.identifier == "GuestVC_FriendTableView" {
            
            guard let indexPath = friendsTableView.indexPathForSelectedRow else {
                return
            }
            
            let guestvc = segue.destination as! GuestVC
            let id = requestedUsers[indexPath.row]["id"] as! Int
            let firstName = requestedUsers[indexPath.row]["firstName"] as! String
            let lastName = requestedUsers[indexPath.row]["lastName"] as! String
            let avaPath = requestedUsers[indexPath.row]["ava"] as! String
            let coverPath = requestedUsers[indexPath.row]["cover"] as! String
            let bio = requestedUsers[indexPath.row]["bio"] as! String
            let isFollowed = requestedUsers[indexPath.row]["followed_user"] as? Int ?? Int()
            let allow_friends = requestedUsers[indexPath.row]["allow_friends"] as? Int ?? Int()
            let allow_follow = requestedUsers[indexPath.row]["allow_follow"] as? Int ?? Int()
            
            guestvc.id = id
            guestvc.firstName = firstName
            guestvc.lastName = lastName
            guestvc.avaPath = avaPath
            guestvc.coverPath = coverPath
            guestvc.bio = bio
            guestvc.friendshipStatus = 2 // request is received by the current user
//            guestvc.allow_friends = allow_friends
//            guestvc.allow_follow = allow_follow
            guestvc.isFollowed = isFollowed
            guestvc.allow_friends = allow_friends
            guestvc.allow_follow = allow_follow
            
        }
    }
    
    @objc func loadRequests() {
        
        isLoading = true;
        
        guard let id = currentUser?["id"] else {
            return
        }
        //http://localhost/fb/friends.php?action=requests&id=11&limit=10&offset=0
        let url = URL(string: "http://\(serverIP)/fb/friends.php")!
        let body = "action=requests&id=\(id)&limit=\(requestedLimit)&offset=0"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                if error != nil {
                    self.isLoading = false
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, showIn: self)
                    return
                }
                
                
                do {
                    
                    guard let data = data else {
                        self.isLoading = false
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, showIn: self)
                        return
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    guard let requests = json?["requests"] as? [NSDictionary] else {
                        
                        //reload cotent of arrays
                        self.requestedUsers.removeAll(keepingCapacity: false)
                        self.requestedUsers_avas.removeAll(keepingCapacity: false)
                        self.requestedUsersSkip = 0
                        self.friendsTableView.reloadData()
                        
                        self.isLoading = false
                        return
                    }
                    
                    self.requestedUsers = requests
                    
                    self.requestedUsersSkip = requests.count
                    
                    self.friendsTableView.reloadData()
                    
                    
                } catch {
                    self.isLoading = false
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, showIn: self)
                    return
                }
            }
            
        }.resume()
    }
    
}
