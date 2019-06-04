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

// MARK: Scripts
enum Scripts: String {
    case darkMode = "DarkMode"
    case accentColour = "AccentColour"
    case nightShift = "NightShift"
    case autoHideDock = "AutoHideDock"
    case openPreferences = "OpenPreferences"
    case quitPreferences = "QuitPreferences"
    case killRunningApplications = "KillAll"
}

// MARK: Apps requiring special treatment
enum AppSpecificBehaviour: String {
    case chrome = "com.google.Chrome"
    case finder = "com.apple.finder"
}

// MARK: Queue
enum CustomQueue: String {
    case files = "mamiksik.states"
    case appleScript = "mamiksik.appleScript"
}
