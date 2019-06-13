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
import RealmSwift

// MARK: - Realm entity declaration
class Profile: BaseEntity {
    @objc dynamic var name = ""
    @objc dynamic var defaultProfile = false
    @objc dynamic var darkMode: Options = .keep
    @objc dynamic var nightShift: Options = .keep
    @objc dynamic var accentColour: Color = .keep
    @objc dynamic var closeOtherApps: Bool = false

    @objc dynamic var wifiName = ""

    @objc dynamic var shortcutKeyCode: Int = -1
    @objc dynamic var shortcutModifierCode: Int = -1

    let apps = List<App>()
    let workflows = List<Workflow>()
}

// MARK: Comperable
extension Profile {
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.name == rhs.name
    }

    static func != (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.name != rhs.name
    }
}
