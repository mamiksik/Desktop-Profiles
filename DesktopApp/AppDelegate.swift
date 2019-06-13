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

import Cocoa
import LaunchAtLogin
import CoreWLAN
import RealmSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    override init() {
        super.init()
        Migrations.configureMigration()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        LaunchAtLogin.isEnabled = UserDefaults.standard.bool(forKey: "launchOnStartup")

        if UserDefaults.standard.bool(forKey: .betaFeatures) {
        let client = CWWiFiClient.shared()
            client.delegate = self
            do {
                try client.startMonitoringEvent(with: .ssidDidChange)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

extension AppDelegate: CWEventDelegate {
    func ssidDidChangeForWiFiInterface(withName interfaceName: String) {

        guard
            let realm = try? Realm(),
            let interface = CWWiFiClient.shared().interface(withName: interfaceName),
            let name = interface.ssid()
            else {
                return
        }

        let results = realm.objects(Profile.self).filter("wifiName == %s AND wifiName != ''", name)

        for result in results {
           result.restoreAll()
        }
    }
}
