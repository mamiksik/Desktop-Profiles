//
//  PreferencesViewController .swift
//  DesktopProfiles
//
//  Created by Martin Miksik on 03/06/2019.
//  Copyright © 2019 Martin Miksik. All rights reserved.
//

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
        enableRemoteControl.isEnabled = !enableRemoteControl.isEnabled
        remoteControllKey.isEnabled = !remoteControllKey.isEnabled

        enableRemoteControl.state = .off
        defaults.set(betaFeatures.state, forKey: .betaFeatures)
    }
}
