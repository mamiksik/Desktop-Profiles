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
import MultipeerConnectivity

enum InstanceServiceCommand: Int {
    case sendProfiles
    case restoreProfile
}

protocol InstanceServiceDelegate: AnyObject {
    func connectedDevicesChanged (manager: InstanceService, connectedDevices: [String])
//    func profileListReceived (manager : InstanceService, profiles: [String])
    func profileListReceived (manager: InstanceService, host: String, profiles: [String])
}
extension InstanceServiceDelegate {
    func restoreProfile (manager: InstanceService, profileName: String) {  }
    func profileListReceived (manager: InstanceService, host: String, profiles: [String]) {  }
}

class InstanceService: NSObject {

    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    let serviceType = "ma-desktop"

    let serviceAdvertiser: MCNearbyServiceAdvertiser
    let serviceBrowser: MCNearbyServiceBrowser

    #if os(OSX)
    let myPeerId = MCPeerID(displayName: "osx - \(Host.current().name!)")
    #elseif os(iOS)
    let myPeerId = MCPeerID(displayName: "ios - \(UIDevice.current.name)")
    #endif

    weak var delegate: InstanceServiceDelegate?

    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .optional)
        session.delegate = self
        return session
    }()

    var connectedDevices: Int {
        return session.connectedPeers.count
    }

    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)

        super.init()

        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()

        self.serviceBrowser.delegate = self
        #if os(iOS)
        self.serviceBrowser.startBrowsingForPeers()
        #endif
    }

    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }

    func send (command: InstanceServiceCommand, data: Data) {
        if session.connectedPeers.count <= 0 {
            return
        }

        if command == .restoreProfile {
            let peers = session.connectedPeers.filter { $0.displayName.contains("osx") }
            try? self.session.send(data, toPeers: peers, with: .reliable)
        }

        if command == .sendProfiles {
            let peers = session.connectedPeers.filter { $0.displayName.contains("ios") }
            try? self.session.send(data, toPeers: peers, with: .reliable)
        }
    }

}

extension InstanceService: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
       invitationHandler(true, self.session)
    }

}

extension InstanceService: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")

        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }

}

extension InstanceService: MCSessionDelegate {

    func session (_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map {$0.displayName})
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")

        if peerID.displayName.contains("ios") {
            if let name = String(data: data, encoding: .utf8) {
                delegate?.restoreProfile(manager: self, profileName: name)
            }
        }

        if peerID.displayName.contains("osx") {
            if let profiles = NSKeyedUnarchiver.unarchiveObject(with: data) as? Array<String> {
                delegate?.profileListReceived(manager: self, host: peerID.displayName, profiles: profiles)
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }

}
