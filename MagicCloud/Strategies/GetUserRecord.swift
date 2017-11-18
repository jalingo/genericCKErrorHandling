//
//  GetUserRecord.swift
//  MagicCloud
//
//  Created by Hayley McCrory on 11/18/17.
//  Copyright © 2017 Escape Chaos. All rights reserved.
//

import CloudKit

public func getCurrentUserRecord() -> CKRecordID? {
    var result: CKRecordID?
    
    let group = DispatchGroup()
    group.enter()
    
    CKContainer.default().fetchUserRecordID { possibleID, possibleError in
        if let error = possibleError {
            NotificationCenter.default.post(name: MCNotification.cloudIdentity, object: error)
        }
        
        if let id = possibleID { result = id }
        group.leave()
    }
    
    group.wait()
    return result
}