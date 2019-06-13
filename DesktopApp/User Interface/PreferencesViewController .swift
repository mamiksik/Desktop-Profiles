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


import Foundation
import Cocoa
import LaunchAtLogin

extension String  {
    static let launchOnStartup = "launchOnStartup"
    static let remoteControl = "remoteControl"
    static let remoteControlKey = "remoteControlKey"
    static let betaFeatures = "betaFeatures"
}

class PreferencesViewController: NSViewController {

    @IBOutlet weak var launchOnStartup: NSButton!
    @IBOutlet weak var enableRemoteControl: NSButton!
    @IBOutlet weak var remoteControllKey: NSSecureTextField!
    @IBOutlet weak var betaFeatures: NSButton!

    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        enableRemoteControl.state = defaults.stateValue(forKey: .remoteControl)
        launchOnStartup.state = defaults.stateValue(forKey: .launchOnStartup)
        betaFeatures.state = defaults.stateValue(forKey: .betaFeatures)
    }

    @IBAction func lunchOnStartupTriggered(_ sender: Any) {
        defaults.set(launchOnStartup.state, forKey: .launchOnStartup)
        LaunchAtLogin.isEnabled = defaults.bool(forKey: .launchOnStartup)
    }

    @IBAction func remoteControllTriggered(_ sender: Any) {
        defaults.set(enableRemoteControl.state, forKey: .remoteControl)
        defaults.set(remoteControllKey.stringValue, forKey: .remoteControlKey)
    }

    @IBAction func betaFeaturesTriggered(_ sender: Any) {
        defaults.set(false, forKey: .remoteControl)
        defaults.set(betaFeatures.state, forKey: .betaFeatures)

        enableRemoteControl.isEnabled = defaults.bool(forKey: .betaFeatures)
        remoteControllKey.isEnabled = defaults.bool(forKey: .betaFeatures)

        enableRemoteControl.state = .off

    }
}
