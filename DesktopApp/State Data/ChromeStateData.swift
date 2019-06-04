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

final class ChromeStateData: CustomApplicationStateData {
    let profile: Profile
    let app: App

    private let fm = FileManager.default
    private let sourceFolder: URL
    private let bundleData: URL

    private let chromeProfiles = ["Default", "Profile 1", "Profile 2", "Profile 3", "Profile 4", "Profile 5"]
    private let toCopy = ["Current Session", "Current Tabs"]

    init(_ app: App) {
        self.app = app.detached()
        self.profile = app.profile.detached()

        let homeFolder = self.fm.homeDirectoryForCurrentUser
        self.sourceFolder = homeFolder.appendingPathComponent("Library/Application Support/Google/Chrome")
        self.bundleData = Utils.bundleUrl.appendingPathComponent("\(profile.name)/Chrome")
    }

    func copy() throws {
        try? app.close()

        for chromeProfile in chromeProfiles {
            let dirUrl = URL(fileURLWithPath: bundleData.path + "/\(chromeProfile)/")
            if !fm.fileExists(atPath: dirUrl.path) {
                try fm.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: [:])
            }

            let currentSessionSource = currentSessionURL(sourceFolder, forProfile: chromeProfile)
            let currentSessionCopy = currentSessionURL(bundleData, forProfile: chromeProfile)
            if self.fm.isReadableFile(atPath: currentSessionSource) {
                try? self.fm.copyItem(atPath: currentSessionSource, toPath: currentSessionCopy)
            }

            let currentTabsSource = currentTabsURL(sourceFolder, forProfile: chromeProfile)
            let currentTabsCopy = currentTabsURL(bundleData, forProfile: chromeProfile)
            if self.fm.isReadableFile(atPath: currentTabsSource) {
                try? self.fm.copyItem(atPath: currentTabsSource, toPath: currentTabsCopy)
            }
        }

        try? app.open()
    }

    func restore() throws {
        try? app.close()

        for chromeProfile in chromeProfiles {
            let currentSessionSource = currentSessionURL(sourceFolder, forProfile: chromeProfile)
            let currentSessionCopy = currentSessionURL(bundleData, forProfile: chromeProfile)
            if self.fm.isReadableFile(atPath: currentSessionCopy) {
                try? self.fm.removeItem(atPath: currentSessionSource)
                try? self.fm.copyItem(atPath: currentSessionCopy, toPath: currentSessionSource)
            }

            let currentTabsSource = currentTabsURL(sourceFolder, forProfile: chromeProfile)
            let currentTabsCopy = currentTabsURL(bundleData, forProfile: chromeProfile)
            if self.fm.isReadableFile(atPath: currentTabsCopy) {
                try? self.fm.removeItem(atPath: currentTabsSource)
                try? self.fm.copyItem(atPath: currentTabsCopy, toPath: currentTabsSource)
            }
        }

        try? app.open()
    }

    func clean() throws {
        for chromeProfile in chromeProfiles {
            let currentSessionCopy = currentSessionURL(bundleData, forProfile: chromeProfile)
            if self.fm.isDeletableFile(atPath: currentSessionCopy) {
                try self.fm.removeItem(atPath: currentSessionCopy)
            }

            let currentTabsCopy = currentTabsURL(bundleData, forProfile: chromeProfile)
            if self.fm.isDeletableFile(atPath: currentTabsCopy) {
                try self.fm.removeItem(atPath: currentTabsCopy)
            }
        }
    }

    private func currentSessionURL(_ path: URL, forProfile: String) -> String {
        return path.appendingPathComponent("\(forProfile)/Current Session").path
    }

    private func currentTabsURL(_ path: URL, forProfile: String) -> String {
        return path.appendingPathComponent("\(forProfile)/Current Tabs").path
    }
}
