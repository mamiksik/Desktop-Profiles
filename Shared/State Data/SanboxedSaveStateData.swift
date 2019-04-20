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
final class SanboxedStateData: CustomApplicationStateData {
    let profile: Profile
    let app: App
    
    private let fm = FileManager.default
    
    private let systemLibrary: URL
    private let profileLibrary: URL
    
    private let systemState: URL
    private let profileState: URL
    
    init(_ app: App) {
        self.app = app.detached()
        self.profile = app.profile.detached()
        
        self.systemLibrary = self.fm.homeDirectoryForCurrentUser.appendingPathComponent("Library/Containers/\(app.bundleIdentifier)/Data/Library/Saved Application State")
        self.profileLibrary = Utils.bundleUrl.appendingPathComponent("\(profile.name)/SavedState/")
        
        self.systemState = StateDataUtils.stateDataPath(library: systemLibrary, bundle: app.bundleIdentifier)
        self.profileState = StateDataUtils.stateDataPath(library: profileLibrary, bundle: app.bundleIdentifier)
    }
    
    
    func copy() throws {
        try app.close()
        
        try StateDataUtils.createDirectory(at: profileState)
        try? StateDataUtils.clean(at: profileState)
        try StateDataUtils.copy(from: systemState, to: profileState)
        
        try app.open()
    }
    
    func restore() throws {
        try app.close()
        
        try? StateDataUtils.clean(at: systemState)
        try StateDataUtils.copy(from: profileState, to: systemState)
        
        try app.open()
    }
    
    func clean() throws {
        try StateDataUtils.clean(at: profileState)
    }
}
