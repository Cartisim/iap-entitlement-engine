//
//  OrderData.swift
//  
//
//  Created by Cole M on 5/30/23.
//

import Foundation

struct OrderData {
    static var shared = OrderData()

    fileprivate var _orderID: String = ""

    var orderID: String {
        get {
            return _orderID
        }
        set {
            _orderID = newValue
        }
    }
}
