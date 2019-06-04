//
//  Events.swift
//  DesktopProfiles
//
//  Created by Martin Miksik on 04/06/2019.
//  Copyright © 2019 Martin Miksik. All rights reserved.
//

import Cocoa
import MapKit

class EventsController: NSViewController {

    @IBOutlet weak var map: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        // Do view setup here.
    }
}

extension EventsController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("asdasd")
    }
}
