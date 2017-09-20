//
//  ViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 8/3/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import Photos
import MapKit
import Firebase
import MaterialComponents

class MapViewController: UIViewController, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, NewDogInfo {

    @IBOutlet var map: MKMapView!
    
    let newDogButton = MDCFloatingButton()
    var authHandle: AuthStateDidChangeListenerHandle?
    var dogs: [Dog] = [Dog]()
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.map.mapType = .standard
        self.map.showsUserLocation = true
        self.map.userTrackingMode = .follow
        self.map.delegate = self
        self.map.mapType = .hybrid
        self.map.addSubview(newDogButton)
        
        let userDogRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("dogs")
        
        userDogRef.observe(.childAdded, with: { (snapshot) in
            if snapshot.value == nil {
                print("no new dog found")
            } else {
                print("new dog found")
                
                let snapshotValue = snapshot.value as! Dictionary<String, String>
                let dogID = snapshotValue["dogID"]!
                
                let dogRef = Database.database().reference().child("dogs").child(dogID)
                dogRef.observeSingleEvent(of: .value, with: { (snap) in
                    print("Found dog data!")
                    let value = snap.value as! Dictionary<String, String>

                    let newDog = Dog()
                    newDog.name = value["name"]!
                    newDog.breed = value["breed"]!
                    newDog.creator = value["creator"]!
                    newDog.score = Int(value["score"]!)!
                    newDog.imageURL = value["imageURL"]!
                    newDog.location = CLLocationCoordinate2D(latitude: Double(value["latitude"]!)!, longitude: Double(value["longitude"]!)!)

                    URLSession.shared.dataTask(with: URL(string: newDog.imageURL)!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        newDog.picture = UIImage(data: data!)!
                        self.dogs.append(newDog)
                        let annotation  = CustomAnnotation(location: newDog.location, title: newDog.name, subtitle: newDog.creator)
                        annotation.name = newDog.name
                        annotation.breed = newDog.breed
                        annotation.score = newDog.score
                        annotation.creator = newDog.creator
                        annotation.picture = newDog.picture
                        DispatchQueue.main.async {
                            self.map.addAnnotation(annotation)
                        }
                        
                    }).resume()
                })
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //MARK: Setup newDogButton attributes
        newDogButton.setTitle("+", for: .normal)
        newDogButton.sizeToFit()
        newDogButton.addTarget(self, action: #selector(newDogButtonTapped), for: .touchUpInside)
        newDogButton.backgroundColor = UIColor(red: 233/255, green: 116/255, blue: 81/255, alpha: 1)
        
        //MARK: Setup newDogButton layout
        newDogButton.translatesAutoresizingMaskIntoConstraints = false
        newDogButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        newDogButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        
        //MARK: Auto-Logout handler
        authHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if Auth.auth().currentUser == nil {
                self.performSegue(withIdentifier: "showLoginViewController", sender: self)
            }
        })
    }
    
    @objc func newDogButtonTapped() {
        // Get current location
        DispatchQueue.global(qos: .background).async {
            self.delegate.locationManager.requestLocation()
        }
        
        performSegue(withIdentifier: "showNewDogViewController", sender: self)
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        performSegue(withIdentifier: "showLoginViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewDogViewController" {
            let newDogViewController = segue.destination as! NewDogViewController
            newDogViewController.dogInfoDelegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if(annotation is MKUserLocation){
            return nil
        }

        let ident = "pin"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ident)
        if annotationView == nil {
            annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: ident)
            annotationView?.canShowCallout = false
        } else {
            annotationView!.annotation = annotation
        }
        annotationView?.image = UIImage(named: "pin")
        //Set the annotationView image here annotationView.image
//        configureDetailView(annotationView!)
        return annotationView
    }
    
//    func configureDetailView(_ annotationView: MKAnnotationView) {
//        let width = 300
//        let height = 100
//
//        let dogPhotoView = UIView()
//        let views = ["dogPhotoView": dogPhotoView]
//
//        dogPhotoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[dogPhotoView(\(width))]", options: [], metrics: nil, views: views))
//        dogPhotoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[dogPhotoView(\(height))]", options: [], metrics: nil, views: views))
//
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        let creatorLabel = UILabel()
//        let breedLabel = UILabel()
//        let scoreLabel = UILabel()
//
//        for dog in self.dogs {
//            imageView.image = dog.picture
//
//            DispatchQueue.main.async {
//                dogPhotoView.addSubview(imageView)
//
//                self.view.layoutIfNeeded()
//            }
//
//        }
//
//        annotationView.detailCalloutAccessoryView = dogPhotoView
//    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for aView in views {
            if aView.reuseIdentifier == "pin" {
                aView.transform = CGAffineTransform(scaleX: 0, y: 0)
                aView.alpha = 0
                UIView.animate(withDuration:0.8) {
                    aView.alpha = 1
                    aView.transform = .identity
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        }
        
        let customAnnotation = view.annotation as! CustomAnnotation
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCalloutView
        calloutView.nameLabel.text = customAnnotation.name
        calloutView.breedLabel.text = customAnnotation.breed
        calloutView.scoreLabel.text = String(describing: customAnnotation.score)
        calloutView.creatorLabel.text = customAnnotation.creator
        calloutView.dogImageView.image = customAnnotation.picture
        calloutView.upvoteButton.addTarget(self, action: #selector(upvoteTapped(_:)), for: .touchUpInside)
        
        calloutView.center = CGPoint(x: view.bounds.size.width/2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: CustomAnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
    func dogDataReceived(name: String, breed: String, score: Int, image: UIImage) {
        
    }
    
    @IBAction func accountButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showAccountViewController", sender: self)
    }
    @IBAction func disoverButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showUserSearch", sender: self)
    }
    
    @objc func upvoteTapped(_ sender: UIButton) {
        
    }
}
