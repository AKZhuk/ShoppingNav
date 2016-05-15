//
//  NavigateController.swift
//  ShoppingNav
//
//  Created by 	Lesha Zhuk on 15.05.16.
//  Copyright © 2016 	Lesha Zhuk. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
        var geoPointCompass: GeoPointCompass!
    var lantitude: Double!
    var lontitude: Double!
    
    
    override func viewDidLoad() {
        print("\(lantitude)")
        print("\(lontitude)")
        self.view.autoresizingMask = ([UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight])
        self.view.backgroundColor = UIColor.blueColor()
        let arrowImageView: UIImageView = UIImageView(frame: CGRectMake(100, 200, 100, 100))
        arrowImageView.image = UIImage(named: "arrow.png")
        self.view.addSubview(arrowImageView)
        arrowImageView.center = self.view.center
        geoPointCompass = GeoPointCompass()
        geoPointCompass.arrowImageView = arrowImageView
        geoPointCompass.lantitude = lantitude
        geoPointCompass.longitude = lontitude
    }
    @IBOutlet weak var Distance: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if CLLocationManager.locationServicesEnabled() {
            geoPointCompass.locationManager.startUpdatingLocation()
            geoPointCompass.locationManager.startUpdatingHeading()
        }
    }
}

