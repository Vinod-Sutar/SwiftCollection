//
//  MPCManager.swift
//  SwiftCollectionView
//
//  Created by Vinod on 03/09/17.
//  Copyright © 2017 BBI-M USER1033. All rights reserved.
//

import Cocoa
import MultipeerConnectivity

protocol MPCManagerDelegate {
    
    func foundPeer()
    
    func lostPeer()
    
    func invitationWasReceived(fromPeer: String)
    
    func connectedWithPeer(peerID: MCPeerID)
}

class MPCManager: NSObject {
    
    var delegate: MPCManagerDelegate?
    
    var session: MCSession!
    
    var peer: MCPeerID!
    
    var browser: MCNearbyServiceBrowser!
    
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    
    var invitationHandler: ((Bool, MCSession)->Void)!
    
    
    override init() {
        super.init()
        
        peer = MCPeerID(displayName:Host.current().localizedName!)
        
        session = MCSession(peer: peer)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "chat-files")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "chat-files")
        advertiser.delegate = self
    }
}

extension MPCManager: MCSessionDelegate {

    // Remote peer changed state.
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        switch state{
        case .connected:
            print("Connected to session: \(session)")
            
        case .connecting:
            print("Connecting to session: \(session)")
            
        default:
            print("Did not connect to session: \(session)")
        }
    }
    
    
    // Received data from remote peer.
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    
    // Received a byte stream from remote peer.
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    
    // Start receiving a resource from remote peer.
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    
    // Finished receiving a resource from remote peer and saved the content
    // in a temporary location - the app is responsible for moving the file
    // to a permanent location within its sandbox.
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
}

extension MPCManager: MCNearbyServiceBrowserDelegate {
    
    // Found a nearby advertising peer.
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
    }
    
    // A nearby peer has stopped advertising.
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
}

extension MPCManager: MCNearbyServiceAdvertiserDelegate {
    
    // Incoming invitation request.  Call the invitationHandler block with YES
    // and a valid session to connect the inviting peer to the session.
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Swift.Void) {
        self.invitationHandler = invitationHandler
    }

}

