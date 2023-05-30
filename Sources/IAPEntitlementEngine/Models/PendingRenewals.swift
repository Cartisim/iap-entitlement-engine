//
//  PendingRenewalInfo.swift
//  
//
//  Created by Cole M on 5/30/23.
//

import Vapor

public struct PendingRenewalInfo: Content {
    var auto_renew_product_id: String
    var original_transaction_id: String
    var auto_renew_status: String
    var expiration_intent: String?
    var grace_period_expires_date: String?
    var grace_period_expires_date_ms: String?
    var grace_period_expires_date_pst: String?
    var is_in_billing_retry_period: String?
    var offer_code_ref_name: String?
    var price_consent_status: String?
    var product_id: String?

    public init(auto_renew_product_id: String, original_transaction_id: String, auto_renew_status: String, expiration_intent: String? = nil, grace_period_expires_date: String? = nil, grace_period_expires_date_ms: String? = nil, grace_period_expires_date_pst: String? = nil, is_in_billing_retry_period: String? = nil, offer_code_ref_name: String? = nil, price_consent_status: String? = nil, product_id: String? = nil) {
        self.auto_renew_product_id = auto_renew_product_id
        self.original_transaction_id = original_transaction_id
        self.auto_renew_status = auto_renew_status
        self.expiration_intent = expiration_intent
        self.grace_period_expires_date = grace_period_expires_date
        self.grace_period_expires_date_ms = grace_period_expires_date_ms
        self.grace_period_expires_date_pst = grace_period_expires_date_pst
        self.is_in_billing_retry_period = is_in_billing_retry_period
        self.offer_code_ref_name = offer_code_ref_name
        self.price_consent_status = price_consent_status
        self.product_id = product_id
    }
}
