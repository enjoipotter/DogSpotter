//
//  LeaderboardViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 11/1/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import Firebase

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var folllowersFollowingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var topUserLabel: UILabel!
    @IBOutlet weak var secondUserLabel: UILabel!
    @IBOutlet weak var thirdUserLabel: UILabel!
    @IBOutlet weak var leaderboardTableView: UITableView!
    var ref: DatabaseReference?
    var userUID: String?
    var myFollowingUsersArray = [User]()
    var myFollowersUsersArray = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
        
        if Auth.auth().currentUser != nil {
            userUID = Auth.auth().currentUser?.uid
            ref = Database.database().reference().child("users")
            
            ref?.child(userUID!).child("following").queryOrdered(byChild: "reputation").observe(.childAdded, with: { (snapshot) in
                self.ref?.child(snapshot.key).observeSingleEvent(of: .value, with: { (snap) in
                    let userToAdd = User()
                    let userDict = snap.value as? [String : AnyObject] ?? [:]
                    
                    userToAdd.username = userDict["username"] as? String
                    userToAdd.reputation = Int((userDict["reputation"] as? String)!)
                    userToAdd.uid = userDict["uid"] as? String
                    self.myFollowingUsersArray.insert(userToAdd, at: 0)
                    self.leaderboardTableView.reloadData()
                })
            })
            ref?.child(userUID!).child("followers").queryOrdered(byChild: "reputation").observe(.childAdded, with: { (snapshot) in
                self.ref?.child(snapshot.key).observeSingleEvent(of: .value, with: { (snap) in
                    let userToAdd = User()
                    let userDict = snap.value as? [String : AnyObject] ?? [:]
                    
                    userToAdd.username = userDict["username"] as? String
                    userToAdd.reputation = Int((userDict["reputation"] as? String)!)
                    userToAdd.uid = userDict["uid"] as? String
                    self.myFollowersUsersArray.insert(userToAdd, at: 0)
                    self.leaderboardTableView.reloadData()
                    
                    switch self.folllowersFollowingSegmentedControl.selectedSegmentIndex {
                    case 0:
                        if self.myFollowersUsersArray.indices.contains(0) {
                            self.topUserLabel.text = "\(String(describing: self.myFollowersUsersArray[0].username!))\n👑\(String(describing: self.myFollowersUsersArray[0].reputation!))"
                        }
                        if self.myFollowersUsersArray.indices.contains(1) {
                            self.secondUserLabel.text = "\(String(describing: self.myFollowersUsersArray[1].username!))\n👑\(String(describing: self.myFollowersUsersArray[1].reputation!))"
                        }
                        if self.myFollowersUsersArray.indices.contains(2) {
                            self.thirdUserLabel.text = "\(String(describing: self.myFollowersUsersArray[2].username!))\n👑\(String(describing: self.myFollowersUsersArray[2].reputation!))"
                        }
                    case 1:
                        if self.myFollowingUsersArray.indices.contains(0) {
                            self.topUserLabel.text = "\(String(describing: self.myFollowingUsersArray[0].username!))\n\(String(describing: self.myFollowingUsersArray[0].reputation!))"
                        }
                        if self.myFollowingUsersArray.indices.contains(1) {
                            self.secondUserLabel.text = "\(String(describing: self.myFollowingUsersArray[1].username!))\n\(String(describing: self.myFollowingUsersArray[1].reputation!))"
                        }
                        if self.myFollowingUsersArray.indices.contains(2) {
                            self.thirdUserLabel.text = "\(String(describing: self.myFollowingUsersArray[2].username!))\n\(String(describing: self.myFollowingUsersArray[2].reputation!))"
                        }
                    default:
                        break
                    }
                })
            })
            

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if folllowersFollowingSegmentedControl.selectedSegmentIndex == 0 {
            return myFollowersUsersArray.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! LeaderboardUserTableViewCell
        if folllowersFollowingSegmentedControl.selectedSegmentIndex == 0 {
            cell.scoreLabel.text = String(describing: myFollowersUsersArray[indexPath.row].reputation!)
            cell.rankAndNameLabel.text = "\(indexPath.row + 1). \(String(describing: myFollowersUsersArray[indexPath.row].username!))"
        }
        return cell
    }
}
