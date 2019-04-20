/* Copyright (C) Martin Miksik 2019

   This file is part of Desktop Profile

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import UIKit

class ViewController: UIViewController {

    let instanceService = InstanceService()

    @IBOutlet weak var connectedDevices: UILabel!
    @IBOutlet weak var profileName: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        instanceService.delegate = self
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
