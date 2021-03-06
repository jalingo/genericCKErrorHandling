//
//  MCDownload.swift
//  MagicCloud
//
//  Created by Jimmy Lingo on 5/21/17.
//  Copyright © 2017 Escape Chaos. All rights reserved.
//

import CloudKit

/**
    Downloads records from specified database, converts them back to recordables and then loads them into associated receiver. Destination is the receiver's 'recordables' property, an array of receiver's associated type, but array is NOT emptied or otherwise prepared before appending results.
 */
public class MCDownload<R: MCMirrorAbstraction>: Operation, MCDatabaseQuerier, MCCloudErrorHandler {

    // MARK: - Properties
    
    /**
        A CKQuery object manages the criteria to apply when searching for records in a database. You create a query object as the first step in the search process. The query object stores the search parameters, including the type of records to search, the match criteria (predicate) to apply, and the sort parameters to apply to the results. The second step is to use the query object to initialize a CKQueryOperation object, which you then execute to generate the results.
     
        Always designate a record type and predicate when you create a query object. The record type narrows the scope of the search to one type of record, and the predicate defines the conditions for which records of that type are considered a match. Predicates usually compare one or more fields of a record to constant values, but you can create predicates that return all records of a given type or perform more nuanced searches.
     
        Because the record type and predicate cannot be changed later, you can use the same CKQuery object to initialize multiple CKQueryOperation objects, each of which targets a different database or zone.
     */
    var query: CKQuery
    
    // MARK: - MCDatabaseQuerier
    
    /**
     The maximum number of records to return at one time.
     
     For most queries, leave the value of this property set to the default value, which is represented by the **CKQueryOperationMaximumResults** constant. When using that value, the server chooses a limit that aims to provide an optimal number of results that returns as many records as possible while minimizing delays in receiving those records. However, if you know that you want to process a fixed number of results, change the value of this property accordingly.
     */
    var limit: Int?
    
    /// This property stores a customized completion block triggered by `Unknown Item` errors.
    var unknownItemCustomAction: OptionalClosure
    
    /// This is the receiver that downloaded records will be sent to as instances conforming to Recordable.
    let receiver: R
    
    /// This read-only property returns the target cloud database for operation.
    let database: MCDatabase
    
    // MARK: - Functions
    
    // MARK: - Functions: Operation
    
    /// If not cancelled, this method override will decorate and launch a CKQueryOperation in the specifified database.
    public override func main() {
        if isCancelled { return }
        
        let op = CKQueryOperation(query: query)
        setupQuerier(op)
        
        if isCancelled { return }

        database.db.add(op)
        
        if isCancelled { return }
        
        op.waitUntilFinished()
    }
    
    // MARK: - Functions: Constructors
    
    /**
        This init constructs a 'MCDownload' operation with a predicate that attempts to match a specified field's value.
     
        - parameter type: Every 'MCDownload' op targets a specifc recordType and this parameter is how it's injected.
        - parameter queryField: 'K' in "%K IN %@" predicate, where K represents CKRecord Field.
        - parameter queryValues: '@' in "%K IN %@" predicate, where @ represents an array of possible matching CKRecordValue's.
        - parameter to: Instance conforming to 'RecievesRecordable' that will ultimately recieve the results of the query.
        - parameter from: 'CKDatabase' that will be searched for records. Leave nil to search default of both private and public.
     */
    public convenience init(type: String, queryField: String, queryValues: [CKRecordValue], to rec: R, from db: MCDatabase) {
        let predicate = NSPredicate(format: "%K IN %@", queryField, queryValues)
        self.init(type: type, matching: predicate, to: rec, from: db)
    }
    
    /**
     This init constructs a 'MCDownload' operation with a predicate that collects all records of the specified type.
     
     - parameter type: Every 'MCDownload' op targets a specifc recordType and this parameter is how it's injected.
     - parameter to: Instance conforming to 'RecievesRecordable' that will ultimately recieve the results of the query.
     - parameter from: 'CKDatabase' that will be searched for records. Leave nil to search default of both private and public.
     */
    public convenience init(type: String, to rec: R, from db: MCDatabase) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        self.init(type: type, matching: predicate, to: rec, from: db)
    }
    
    /**
        This init constructs a 'MCDownload' operation with a custom predicate.
     
        - parameter type: Every 'MCDownload' op targets a specifc recordType and this parameter is how it's injected.
        - parameter predicate: The predicate for CKQuery to test against.
        - parameter to: Instance conforming to 'RecievesRecordable' that will ultimately recieve the results of the query.
        - parameter from: 'CKDatabase' that will be searched for records. Leave nil to search default of both private and public.
     */
    public init(type: String, matching predicate: NSPredicate, to rec: R, from db: MCDatabase) {
        query = CKQuery(recordType: type, predicate: predicate)
        receiver = rec
        database = db
        
        super.init()
        
        self.name = "\(Date.timeIntervalBetween1970AndReferenceDate) - MCDownload \(query.description) from \(self.database)"
    }
}
