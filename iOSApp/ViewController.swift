//
//  ViewController.swift
//  iOSApp
//
//  Created by Martin Miksik on 10/02/2019.
//  Copyright © 2019 Martin Miksik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let instanceService = InstanceService()
    
    
    @IBOutlet weak var connectedDevices: UILabel!
    @IBOutlet weak var profileName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instanceService.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func sendTapped(_ sender: Any) {
        instanceService.send(command: profileName.text!)
    }
}

extension ViewController : InstanceServiceDelegate {
    
    func connectedDevicesChanged(manager: InstanceService, connectedDevices: [String]) {
        DispatchQueue.main.async {
            self.connectedDevices.text = "Connections: \(connectedDevices.count)"
        }
    }
    
    func profileChanged(manager: InstanceService, profileName: String) {
    }
}
