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

// MARK: Custom init
extension Workflow {
    convenience init(forPath: String, forProfile: Profile) throws {
        let source = URL(fileURLWithPath: forPath)
        let location = Utils.bundleUrl.appendingPathComponent("Workflows/\(forProfile.name)")
        let fm = FileManager.default

        if !fm.fileExists(atPath: location.path) {
            try? fm.createDirectory(at: location, withIntermediateDirectories: true, attributes: [:])
        }

        let filePath = location.path + "/\(source.lastPathComponent)"
        try fm.copyItem(atPath: source.path, toPath: filePath)

        self.init()
        self.name = source.lastPathComponent
        self.path = filePath
    }
}

// MARK: Custom Profile methods
extension Workflow {
    func run() throws {
        let scriptQueue = DispatchQueue(label: CustomQueue.appleScript.rawValue)
        let path = self.path.replacingOccurrences(of: " ", with: "\\ ")

        scriptQueue.async {
            _ = try? shellOut(to: "/usr/bin/automator", arguments: [path])
        }
    }
}
