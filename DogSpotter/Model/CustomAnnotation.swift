//
//  Annotation.swift
//  DogSpotter
//
//  Created by Cody Potter on 8/30/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import Foundation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate : CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    var creator: String = ""
    var name: String = ""
    var breed: String = ""
    var score: Int = 1
    var picture = UIImage()
    var dogID: String  = ""
    
    init(location: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = location
        self.title = title
        self.subtitle = title
        super.init()
    }
    
    init(dog: Dog) {
        self.coordinate = dog.location
        self.title = dog.name
        self.subtitle = dog.breed!
        self.creator = dog.creator!
        self.name = dog.name!
        self.breed = dog.breed!
        self.score = dog.score!
        self.picture = dog.picture
        self.dogID = dog.dogID!
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
