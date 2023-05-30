//
//  Request+Extension.swift
//  
//
//  Created by Cole M on 5/30/23.
//

import Vapor

extension Request {
    // MARK: Repositories
    public var orders: OrderRepository { application.repositories.orders.for(self) }
}
