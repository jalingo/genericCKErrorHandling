//
//  Duplicate.swift
//  slBackend
//
//  Created by Jimmy Lingo on 5/29/17.
//  Copyright © 2017 Escape Chaos. All rights reserved.
//

import Foundation
import CloudKit

/// Types conforming to this protocol will be able to replicate several Magic Cloud operations.
protocol MCOperationReplicator {
    
    /**
        This function takes the originatingOp (which has already been spent) and creates a new version with the same property values and completion blocks.
     
        - Parameters:
            - op: The operation to be duplicated.
            - receiver: The receiver type associated with the operation.
        - Returns: If not nil, then operation was successfully replicated.
     */
    func replicate<R: MCMirrorAbstraction>(_ op: Operation, with receiver: R) -> Operation?
}

extension MCOperationReplicator {
    
    func replicate<R: MCMirrorAbstraction>(_ op: Operation, with receiver: R) -> Operation? {
        
        // Custom Operations
        
        if let failure = op as? FailedOp { return FailedOp(notify: failure.notification) }
        
        // Custom Recordable Operations
        
        if let uploader = op as? MCUpload<R> {
            let new = MCUpload<R>(uploader.recordables, from: receiver, to: uploader.database)
            
            new.completionBlock = uploader.completionBlock
            new.name = "\(String(describing: uploader.name))+"
            
            return new
        }
        
        if let deleter = op as? MCDelete<R> {
            let new = MCDelete<R>(deleter.recordables, of: receiver, from: deleter.database)
            
            new.delayInSeconds = deleter.delayInSeconds
            new.completionBlock = deleter.completionBlock
            new.name = "\(String(describing: deleter.name))+"
            
            return new
        }
        
        if let downloader = op as? MCDownload<R> {
            let new = MCDownload<R>(type: downloader.query.recordType, to: downloader.receiver, from: downloader.database)
            
            new.query = downloader.query
            new.unknownItemCustomAction = downloader.unknownItemCustomAction
            new.limit = downloader.limit
            new.completionBlock = downloader.completionBlock
            new.name = "\(String(describing: downloader.name))+"
            
            return new
        }
        
        // CKDatabaseOperations
        
        if let fetcher = op as? CKFetchRecordsOperation {
            guard let ids = fetcher.recordIDs else { return nil }
            
            let new = CKFetchRecordsOperation(recordIDs: ids)
            
            new.completionBlock = fetcher.completionBlock
            new.fetchRecordsCompletionBlock = fetcher.fetchRecordsCompletionBlock
            new.perRecordProgressBlock = fetcher.perRecordProgressBlock
            new.perRecordCompletionBlock = fetcher.perRecordCompletionBlock
            new.name = fetcher.name
            
            return new
        }
        
        if let modifier = op as? CKModifyRecordsOperation {
            
            let new = CKModifyRecordsOperation(recordsToSave: modifier.recordsToSave,
                                               recordIDsToDelete: modifier.recordIDsToDelete)
            new.completionBlock = modifier.completionBlock
            new.modifyRecordsCompletionBlock = modifier.modifyRecordsCompletionBlock
            new.perRecordCompletionBlock = modifier.perRecordCompletionBlock
            new.perRecordProgressBlock = modifier.perRecordProgressBlock
            new.name = modifier.name
            
            return new
        }
        
        if let querier = op as? CKQueryOperation {
            let new: CKQueryOperation
            
            if let cursor = querier.cursor {
                new = CKQueryOperation(cursor: cursor)
            } else if let query = querier.query {
                new = CKQueryOperation(query: query)
            } else { return nil }
            
            new.completionBlock = querier.completionBlock
            new.queryCompletionBlock = querier.queryCompletionBlock
            new.recordFetchedBlock = querier.recordFetchedBlock
            new.name = querier.name
            
            return new
        }
        
        return nil
    }
}


