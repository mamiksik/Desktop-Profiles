//
//  Api.swift
//  Maturitka
//
//  Created by Martin Miksik on 12/12/2018.
//  Copyright © 2018 Martin Miksik. All rights reserved.
//

import Foundation
import RealmSwift
import ShellOut

class MMApplications {

    public func close(app: App){
        if var pid = try? shellOut(to: "pgrep \(app.name)") {
            pid = pid.replacingOccurrences(of: "\n", with: " ")
            let result = try? shellOut(to: "kill \(pid)")
            print(result)
        }
    }

    func open(app: App) {
        let appName = app.name == "iTerm2" ? "iTerm": app.name
        NSWorkspace.shared.launchApplication(appName)
    }
}
