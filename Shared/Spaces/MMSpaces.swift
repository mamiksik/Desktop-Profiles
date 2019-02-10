import Foundation
//import SwiftSocket

struct Space {
    let displayID: String
    let position: Int
    let type: Int
    let id: Int?
}

class MMSpaces {
    static let Shared = MMSpaces()
    var spaces: [Space] {
        get {
//            guard let spaces = CGSCopyManagedDisplaySpaces(_CGSDefaultConnection()) else {
                return []
//            }
            
//            var result: [Space] = []
//            for desktops in spaces.takeUnretainedValue() as! [NSDictionary] {
//                let displayID: String = desktops["Display Identifier"] as! String
//                for (index, space) in (desktops["Spaces"] as! [NSDictionary]).enumerated() {
//                    result.append(
//                        Space(displayID: displayID,
//                              position: index,
//                              type: space["type"] as! Int,
//                              id: space["id64"] as! Int
//                    ))
//
//                }
//            }
//            return result
        }
    }
    
    private init(){}
    
    func addSpace(after: Space) {}
    func destroy(space: Space) {}
    func destroyAll() {
//        let client = TCPClient(address: "localhost", port: 5050)
//        switch client.connect(timeout: 10) {
//        case .success:
//                print("😍")
//            case .failure(let error):
//                print("💩: \(error)" )
//            return
//        }

        
//        for space in self.spaces {
//            client.send(string: "space_destroy \(space.position)")
//        }
    }
    
    func moveWindow(toSpace: Space) {}
    
}
