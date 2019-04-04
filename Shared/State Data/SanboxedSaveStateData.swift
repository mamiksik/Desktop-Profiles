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
