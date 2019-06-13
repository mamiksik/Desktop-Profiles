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

final class Migrations {

    static let currentSchemaVersion: UInt64 = 0

    static func configureMigration() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    migrateFrom0To1(with: migration)
                }
        })
        Realm.Configuration.defaultConfiguration = config
    }

    static func migrateFrom0To1(with migration: Migration) {
        // Add an email property
        migration.enumerateObjects(ofType: Profile.className()) { _, newObject in
            newObject!["wifiName"] = ""
        }
    }
}
