//
//  SQLRow.swift
//  LittlinkRouterPerfect
//
//  Created by Brent Royal-Gordon on 10/30/16.
//
//

/// Represents a row of data within a `SQLQuery`.
/// 
/// A `SQLRow` contains one or more encapsulated values, which you can retrieve by 
/// calling the `value(for:)` method and passing a `SQLColumnKey` constructed from 
/// the `SQLQuery`.
/// 
/// - Warning: There is no guarantee that the data in a `SQLRow` will continue to 
///               be accessible once you've iterated the query to retrieve the next 
///               `SQLRow`.
public struct SQLRow<Client: SQLClient> {
    /// The statement executed to create this query.
    public let statement: SQLStatement
    /// The state object backing this instance. State objects are client-specific, 
    /// and some clients may expose low-level data structures through the state 
    /// object.
    public var state: Client.RowState
    
    /// Returns the value in the column indicated by the provided key.
    /// 
    /// - Throws: If a connection error occurs, if the value is `NULL` and the key 
    ///             is not a `SQLNullableColumnKey`, or if the value is not of the 
    ///             appropriate type.
    /// 
    /// - Parameter key: The key for the column whose value you want to read. Keys 
    ///                     are created by calling the `columnKey(forName:as:)` or 
    ///                     `columnKey(at:as:)` methods on the query.
    /// 
    /// - Precondition: `key` must have come from the same `SQLQuery` as `self`.
    public func value<Value: SQLValue>(for key: SQLColumnKey<Value>) throws -> Value {
        return try withErrorsPackaged(in: SQLError.makeValueInvalid(with: statement, for: key)) {
            guard let value = try Client.value(for: key, with: state) else { 
                throw SQLValueError.valueNull
            }
            return value
        }
    }
    
    /// Returns the value in the column indicated by the provided key.
    /// 
    /// - Throws: If a connection error occurs, if the value is `NULL` and the key 
    ///             is not a `SQLNullableColumnKey`, or if the value is not of the 
    ///             appropriate type.
    /// 
    /// - Parameter key: The key for the column whose value you want to read. Keys 
    ///                     are created by calling the `columnKey(forName:as:)` or 
    ///                     `columnKey(at:as:)` methods on the query.
    /// 
    /// - Precondition: `key` must have come from the same `SQLQuery` as `self`.
    public func value<Value: SQLValue>(for key: SQLNullableColumnKey<Value>) throws -> Value? {
        return try withErrorsPackaged(in: SQLError.makeValueInvalid(with: statement, for: key)) {
            try Client.value(for: key.nonnullColumnKey, with: state)
        }
    }
}

