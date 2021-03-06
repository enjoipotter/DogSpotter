//
//  FriendSearchTableViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 9/18/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import Firebase

class FriendSearchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet var followUsersTableView: UITableView!
    var usersArray = [User]()
    var filteredUsers = [User]()
    var databaseRef = Database.database().reference()
    var chosenUser = User()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = UIColor(red: 229/255, green: 75/255, blue: 75/255, alpha: 1)
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar

        databaseRef.child("users").queryOrdered(byChild: "username").observe(.childAdded) { (snapshot) in
            let blockedRef = self.databaseRef.child("users").child((Auth.auth().currentUser?.uid)!).child("blocked").child(snapshot.key)
            blockedRef.observeSingleEvent(of: .value, with: { (snap) in
                if !snap.exists() {
                    let queriedUser = User()
                    
                    let value = snapshot.value as? NSDictionary
                    queriedUser.email = value?["email"] as? String ?? ""
                    queriedUser.name = value?["name"] as? String ?? ""
                    queriedUser.reputation = Int(value?["reputation"] as? String ?? "0")
                    queriedUser.timestamp = Int(value?["timestamp"] as? String ?? "0")
                    queriedUser.uid = snapshot.key
                    queriedUser.username = value?["username"] as? String ?? ""
                    self.usersArray.append(queriedUser)
                    
                    //insert the rows
                    
                    self.followUsersTableView.insertRows(at: [IndexPath(row: self.usersArray.count-1, section: 0)], with: UITableViewRowAnimation.automatic)
                }
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUsers.count
        }
        return self.usersArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        var user = User()
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
            
        } else {
            user = self.usersArray[indexPath.row]
        }
        
        cell.textLabel?.text = user.username
        cell.detailTextLabel?.text = user.name
        
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        //update the search results
        filterContent(searchText: self.searchController.searchBar.text!)
    }
    
    func filterContent(searchText: String) {
        self.filteredUsers = self.usersArray.filter{ user in
            let username = user.username
            return(username?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        if searchController.isActive && searchController.searchBar.text != "" {
            chosenUser = filteredUsers[indexPath.row]
        } else {
            chosenUser = usersArray[indexPath.row]
        }
        performSegue(withIdentifier: "showDogTableViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDogTableViewController" {
            
            let destinationController = segue.destination as! DogTableViewController
            destinationController.user = chosenUser
        }
    }
}




