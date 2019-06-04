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
    @IBOutlet weak var profilePicker: UIPickerView!

    var pickerData: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        instanceService.delegate = self

        self.profilePicker.delegate = self
        self.profilePicker.dataSource = self

//        self.serviceAdvertiser.startAdvertisingPeer()
    }

    @IBAction func sendTapped(_ sender: Any) {
        let name = pickerData[profilePicker.selectedRow(inComponent: 0)]
        instanceService.send(command: .restoreProfile, data: name.data(using: .utf8)!)
    }
}

extension ViewController: InstanceServiceDelegate {

    func connectedDevicesChanged(manager: InstanceService, connectedDevices: [String]) {
        print("Connections: \(connectedDevices)")
        DispatchQueue.main.async {
            self.connectedDevices.text = "Connections: \(connectedDevices.count)"
        }
    }

    func profileListReceived(manager: InstanceService, profiles: [String]) {
        pickerData = profiles
        DispatchQueue.main.async {
            self.profilePicker.reloadAllComponents()
        }
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    // Number of columns of data
    func numberOfComponents (in pickerView: UIPickerView) -> Int {
        return 1
    }

    // The number of rows of data
    func pickerView (_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    // The data to return fopr the row and component (column) that's being passed in
    func pickerView (_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}
