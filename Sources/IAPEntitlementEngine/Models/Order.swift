//
//  Order.swift
//  
//
//  Created by Cole M on 5/30/23.
//

import Vapor
import Fluent

public final class Order: Model {
    
    typealias Input = _Input
    
    typealias Output = _Output
    
    
    public static let schema = "orders"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "product_name")
    public var productName: String?
    
    @Field(key: "image_string")
    public var imageString: String?
    
    @Field(key: "currency")
    public var currency: String?
    
    @Field(key: "quantity")
    public var quantity: Int?
    
    @Field(key: "price")
    public var price: Int?
    
    @Field(key: "is_Purchased")
    public var isPurchased: Bool?
    
    @Field(key: "is_subscribed")
    public var isSubscribed: Bool?
    
    @Field(key: "order_description")
    public var orderDescription: String?
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
    
    public init() {}
    
    public init(id: UUID? = nil, productName: String? = "", imageString: String? = "", currency: String? = "", quantity: Int? = 0, price: Int? = 0, isPurchased: Bool? = false, isSubscribed: Bool? = false, orderDescription: String? = "", createdAt: Date? = nil, updatedAt: Date? = nil, deletedAt: Date? = nil) {
        
        self.id = id
        self.productName = productName
        self.imageString = imageString
        self.currency = currency
        self.quantity = quantity
        self.price = price
        self.isPurchased = isPurchased
        self.isSubscribed = isSubscribed
        self.orderDescription = orderDescription
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}


extension Order {
    struct _Input: Content {
        var productName: String?
        var imageString: String?
        var currency: String?
        var quantity: Int?
        var price: Int?
        var isPurchased: Bool?
        var isSubscribed: Bool?
        var orderDescription: String?

        init(productName: String?, imageString: String?, currency: String?, quantity: Int?, price: Int?, isPurchased: Bool?, isSubscribed: Bool? = false, orderDescription: String? = nil) {
            self.productName = productName
            self.imageString = imageString
            self.currency = currency
            self.quantity = quantity
            self.price = price
            self.isPurchased = isPurchased
            self.isSubscribed = isSubscribed
            self.orderDescription = orderDescription
        }

        init(from order: Order) {
            self.init(productName: order.productName, imageString: order.imageString, currency: order.currency, quantity: order.quantity, price: order.price, isPurchased: order.isPurchased)
        }
    }
}


extension Order {
    struct _Output: Content {
        var id: String
        var productName: String?
        var imageString: String?
        var currency: String?
        var quantity: Int?
        var price: Int?
        var isPurchased: Bool?
        var isSubscribed: Bool?
        var orderDescription: String?
        var createdAt: Date?
        var updatedAt: Date?
        var deletedAt: Date?

        init(id: String, productName: String?, imageString: String?, currency: String?, quantity: Int?, price: Int?, isPurchased: Bool?, isSubscribed: Bool?, orderDescription: String?, createdAt: Date?, updatedAt: Date?, deletedAt: Date?) {
            self.id = id
            self.productName = productName
            self.imageString = imageString
            self.currency = currency
            self.quantity = quantity
            self.price = price
            self.isPurchased = isPurchased
            self.isSubscribed = isSubscribed
            self.orderDescription = orderDescription
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.deletedAt = deletedAt
        }

        init(from order: Order) {
            self.init(id: order.id!.uuidString, productName: order.productName, imageString: order.imageString, currency: order.currency, quantity: order.quantity, price: order.price, isPurchased: order.isPurchased, isSubscribed: order.isSubscribed, orderDescription: order.orderDescription, createdAt: order.createdAt, updatedAt: order.updatedAt, deletedAt: order.deletedAt)
        }
    }
}
