//
//  OrderRepository.swift
//  
//
//  Created by Cole M on 5/30/23.
//

import Vapor
import Fluent

public protocol OrderRepository: Repository {
    func create(_ order: Order) -> EventLoopFuture<Void>
    func delete(id: UUID) -> EventLoopFuture<Void>
    func all() -> EventLoopFuture<[Order]>
    func find(id: UUID) -> EventLoopFuture<Order?>
    func set<Field>(_ field: KeyPath<Order, Field>, to value: Field.Value, for orderID: UUID) -> EventLoopFuture<Void> where Field: QueryableProperty, Field.Model == Order
    func count() -> EventLoopFuture<Int>
}

public struct DatabaseOrderRepository: OrderRepository, DatabaseRepository {
    public let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func create(_ order: Order) -> EventLoopFuture<Void> {
        return order
            .create(on: database)
    }
    
    public func delete(id: UUID) -> EventLoopFuture<Void> {
        return Order.query(on: database)
            .filter(\.$id == id)
            .delete(force: true)
    }
    
    public func all() -> EventLoopFuture<[Order]> {
        return Order.query(on: database)
            .filter(\.$id == \._$id).withDeleted()
            .sort(\.$productName, .descending)
            .all()
    }
    
    public func find(id: UUID) -> EventLoopFuture<Order?> {
        return Order.query(on: database)
            .filter(\.$id == id).withDeleted()
            .first()
    }
    
    public func set<Field>(_ field: KeyPath<Order, Field>, to value: Field.Value, for orderID: UUID) -> EventLoopFuture<Void>
    where Field: QueryableProperty, Field.Model == Order
    {
        return Order.query(on: database)
            .filter(\.$id == orderID)
            .set(field, to: value)
            .update()
    }
    
    public func count() -> EventLoopFuture<Int> {
        return Order.query(on: database).count()
    }
}

extension Application.Repositories {
    public var orders: OrderRepository {
        guard let storage = storage.makeOrderRepository else {
            fatalError("OrderRepository not configured, use: app.ordersRepository.use()")
        }
        
        return storage(app)
    }
    
    public func use(_ make: @escaping (Application) -> (OrderRepository)) {
        storage.makeOrderRepository = make
    }
}


