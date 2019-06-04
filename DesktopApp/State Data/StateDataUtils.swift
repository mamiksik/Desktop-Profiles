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

class StateDataUtils {
    static func copy(from: URL, to: URL) throws {
        let fm = FileManager.default
        if fm.isReadableFile(atPath: from.path) {
            try? fm.copyItem(at: from, to: to)
        }
    }

    static func clean(at: URL) throws {
        let fm = FileManager.default
        if fm.isDeletableFile(atPath: at.path) {
            try fm.removeItem(atPath: at.path)
        }
    }

    static func createDirectory(at: URL) throws {
        let fm = FileManager.default
        if !fm.fileExists(atPath: at.path) {
            try fm.createDirectory(at: at, withIntermediateDirectories: true, attributes: [:])
        }
    }

    static func stateDataPath(library: URL, bundle: String) -> URL {
        return library.appendingPathComponent("\(bundle).savedState")
    }
}
