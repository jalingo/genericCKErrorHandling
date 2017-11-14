//
//  CloudNotification.swift
//  slBackend
//
//  Created by James Lingo on 11/12/17.
//  Copyright © 2017 Promethatech. All rights reserved.
//

import Foundation
import CloudKit

public struct MCNotification {
    
    // MARK: - Properties: Static Constants
    
    /// Notification.Name for any CKError detected...
    static let cloudError = Notification.Name("CLOUD_ERROR_OCCURED")
    
    /// Notification.Name for CKError.notAuthenticated...
    static let notAuthenticated = Notification.Name("CLOUD_ERROR_NOT_AUTHENTICATED")
    
    /// Notification.Name for CKError.serverRecordChanged...
    static let serverRecordChanged = Notification.Name("CLOUD_ERROR_CHANGED_RECORD")
    
    /**
        Notification.Name for CKError.limitExceeded, CKError.batchRequestFailed,
        CKError.partialFailure...
     */
    static let batchIssue = Notification.Name("CLOUD_ERROR_BATCH_ISSUE")
    
        /// Notification.Name for CKError.limitExceeded
        static let limitExceeded = Notification.Name("CLOUD_ERROR_LIMIT_EXCEEDED")

        /// Notification.Name for CKError.batchRequestFailed
        static let batchRequestFailed = Notification.Name("CLOUD_ERROR_BATCH_REQUEST")
    
        /// Notification.Name for CKError.partialFailure
        static let partialFailure = Notification.Name("CLOUD_ERROR_PARTIAL_FAILURE")
    
    /**
        Notification.Name for CKError.networkUnavailable, CKError.networkFailure,
        CKError.serviceUnavailable, CKError.requestRateLimited, CKError.zoneBusy,
        CKError.resultsTruncated...
     */
    static let retriable = Notification.Name("CLOUD_ERROR_RETRIABLE")
    
    /**
        Notification.Name for CKError.assetFileModified, CKError.serverRejectedRequest,
        CKError.assteFileNotFound, CKError.badContainer, CKError.serverResponseLost,
        CKError.changeTokenExpired, CKError.constraintViolation, CKError.internalError,
        CKError.incompatibleVersion, CKError.invalidArguments, CKError.quotaExceeded
        CKError.managedAccountRestricted, CKError.participantMayNeedVerification,
        CKError.operationCancelled, CKError.missingEntitlement, CKError.badDatabase,
        CKError.permissionFailure, CKError.referenceViolation, CKError.unknownItem,
        CKError.userDeletedZone, CKError.zoneNotFound...
     */
    static let fatalError = NSNotification.Name("CLOUD_ERROR_FATAL")

    /**
        Notification.Name for CKError.alreadyShared, CKError.tooManyParticipants,
     */
    static let sharingError = NSNotification.Name("CLOUD_ERROR_SHARING")
}
