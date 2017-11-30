//
//  NotificationReader.swift
//  MagicCloud
//
//  Created by James Lingo on 11/22/17.
//  Copyright © 2017 Escape Chaos. All rights reserved.
//

import CloudKit

/// Conforming to this protocol allows remote notifications to be converted to local notifications and triggers behavior.
public protocol NotificationConverter {
    
    /// This method creates a local notification from remote notifiation's userInfo, if intended for MagicCloud.
    /// Implementation for this method should not be overwritten.
    func convertToLocal(from info: [AnyHashable: Any])
}

public extension NotificationConverter {
    
    public func convertToLocal(from info: [AnyHashable: Any]) {
        let notification = CKQueryNotification(fromRemoteNotificationDictionary: info)
        
        if let type = notification.alertLocalizationKey {
            let name = Notification.Name(type)
            NotificationCenter.default.post(name: name, object: nil, userInfo: info)
        } else {
            print("** userInfo: \(info.values)")
        }
    }
}
