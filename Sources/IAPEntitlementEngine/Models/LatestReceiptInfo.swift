//
//  LatestReceiptInfo.swift
//  
//
//  Created by Cole M on 5/30/23.
//

import Vapor

public struct LatestReceiptInfo: Content {
    var quantity: String
    var product_id: String
    var transaction_id: String
    var original_transaction_id: String
    var purchase_date: String
    var purchase_date_ms: String
    var purchase_date_pst: String
    var original_purchase_date: String
    var original_purchase_date_ms: String
    var original_purchase_date_pst: String
    var expires_date: String
    var expires_date_ms: String
    var expires_date_pst: String
    var web_order_line_item_id: String
    var is_trial_period: String
    var is_in_intro_offer_period: String
    var subscription_group_identifier: String
    var cancellation_date: String?
    var cancellation_date_ms: String?
    var cancellation_date_pst: String?
    var cancellation_reason: String?
    var is_upgraded: String?
    var offer_code_ref_name: String?
    var promotional_offer_id: String?

    public init(quantity: String, product_id: String, transaction_id: String, original_transaction_id: String, purchase_date: String, purchase_date_ms: String, purchase_date_pst: String, original_purchase_date: String, original_purchase_date_ms: String, original_purchase_date_pst: String, expires_date: String, expires_date_ms: String, expires_date_pst: String, web_order_line_item_id: String, is_trial_period: String, is_in_intro_offer_period: String, subscription_group_identifier: String, cancellation_date: String? = nil, cancellation_date_ms: String? = nil, cancellation_date_pst: String? = nil, cancellation_reason: String? = nil, is_upgraded: String? = nil, offer_code_ref_name: String? = nil, promotional_offer_id: String? = nil) {
        self.quantity = quantity
        self.product_id = product_id
        self.transaction_id = transaction_id
        self.original_transaction_id = original_transaction_id
        self.purchase_date = purchase_date
        self.purchase_date_ms = purchase_date_ms
        self.purchase_date_pst = purchase_date_pst
        self.original_purchase_date = original_purchase_date
        self.original_purchase_date_ms = original_purchase_date_ms
        self.original_purchase_date_pst = original_purchase_date_pst
        self.expires_date = expires_date
        self.expires_date_ms = expires_date_ms
        self.expires_date_pst = expires_date_pst
        self.web_order_line_item_id = web_order_line_item_id
        self.is_trial_period = is_trial_period
        self.is_in_intro_offer_period = is_in_intro_offer_period
        self.subscription_group_identifier = subscription_group_identifier
        self.cancellation_date = cancellation_date
        self.cancellation_date_ms = cancellation_date_ms
        self.cancellation_date_pst = cancellation_date_pst
        self.cancellation_reason = cancellation_reason
        self.is_upgraded = is_upgraded
        self.offer_code_ref_name = offer_code_ref_name
        self.promotional_offer_id = promotional_offer_id
    }
}
