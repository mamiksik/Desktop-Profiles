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


// MARK: Entities
@objc enum Options: Int, CaseIterable, CustomStringConvertible {
    case keep
    case setTrue
    case setFalse

    var description: String {
        switch self {
        case .setTrue:  return "true"
        case .setFalse: return "false"
        default:
            return "keep"
        }
    }
}

@objc enum Color: Int, CustomStringConvertible {
    case keep
    case blue
    case purple
    case pink
    case red
    case orange
    case yellow
    case green
    case graphite

    var description: String {
        switch self {
        case .blue:     return "Blue"
        case .purple:   return "Purple"
        case .pink:     return "Pink"
        case .red:      return "Red"
        case .orange:   return "Orange"
        case .yellow:   return "Yellow"
        case .green:    return "Green"
        case .graphite: return "Graphite"
        default:        return "keep"
        }
    }
}
