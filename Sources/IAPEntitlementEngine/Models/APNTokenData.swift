//
//  APNTokenData.swift
//  
//
//  Created by Cole M on 5/30/23.
//

import Foundation

struct APNTokenData {
    static var shared = APNTokenData()

    fileprivate var _token: String = ""

    var token: String {
        get {
            return _token
        }
        set {
            _token = newValue
        }
    }
}
