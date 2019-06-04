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
import ShellOut

// MARK: - Custom init
extension App {
    convenience init(forPath: String) throws {
        guard let bundle = Bundle(path: forPath) else {
            throw AppError.cantGetAppBundle
        }

        guard let name = bundle.infoDictionary![kCFBundleNameKey as String] as? String else {
            throw AppError.cantGetAppName
        }

        self.init()
        self.name = name
        self.bundleIdentifier = bundle.bundleIdentifier!
        self.path = forPath
    }
}

// MARK: - Custom methods
extension App {

    var isSanboxed: Bool {
        return Bundle(path: path)?.ob_isSandboxed() ?? false
    }

    var stateData: CustomApplicationStateData {
        switch bundleIdentifier {
        case AppSpecificBehaviour.chrome.rawValue:
            return ChromeStateData(self)
        default:
            if isSanboxed {
                return SanboxedStateData(self)
            } else {
                return DefaultStateData(self)
            }
        }
    }

    func close() throws {
        if var pid = try? shellOut(to: "pgrep \(self.name)") {
            if self.bundleIdentifier != AppSpecificBehaviour.chrome.rawValue {
                pid = pid.replacingOccurrences(of: "\n", with: " ")
            }
            try shellOut(to: "kill \(pid)")
        }
    }

    func open() throws {
        if AppSpecificBehaviour.finder.rawValue != bundleIdentifier {
            try shellOut(to: "open -b \(self.bundleIdentifier)")
        }
    }
}
