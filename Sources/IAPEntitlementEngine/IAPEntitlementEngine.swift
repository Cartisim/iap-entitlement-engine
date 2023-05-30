//
//  EntitlementEngine.swift
//
//
//  Created by Cole M on 5/30/23.
//

import Vapor
import APNS

public class EntitlementEngine {
    
    public let currentDate = Date()
    public let weeklyProductID: String
    public let monthlyProductID: String
    public let yearlyProductID: String
    
    public init(
        weeklyProductID: String,
        monthlyProductID: String,
        yearlyProductID: String
    ) {
        self.weeklyProductID = weeklyProductID
        self.monthlyProductID = monthlyProductID
        self.yearlyProductID = yearlyProductID
    }
    
    private func isCancelled(latestReceiptInfo: LatestReceiptInfo) -> Bool {
        var cancelled: Bool
        guard let cancellationDate = Int64(latestReceiptInfo.cancellation_date_ms ?? "") else {return false}
        
        if Date(milliseconds: cancellationDate) >= currentDate {
            cancelled = true
        } else {
            cancelled = false
        }
        return cancelled
    }
    
    private func cancellationReason(latestReceiptInfo: LatestReceiptInfo) -> String {
        var reason: String
        if latestReceiptInfo.cancellation_reason == CancellationInteger.cancellationIntegerZero.rawValue {
            reason = CancellationReason.reasonOne.rawValue
        } else {
            reason =  CancellationReason.reasonTwo.rawValue
        }
        return reason
    }
    
    private func isTrial(latestReceiptInfo: LatestReceiptInfo) -> Bool {
        var trial: Bool
        if latestReceiptInfo.is_trial_period == IsTrial.isTrue.rawValue {
            trial = true
        } else {
            trial = false
        }
        return trial
    }
    
    private func isIntroOffer(latestReceiptInfo: LatestReceiptInfo) -> Bool {
        var intro: Bool
        if latestReceiptInfo.is_in_intro_offer_period == IsIntroOffer.isTrue.rawValue {
            intro = true
        } else {
            intro = false
        }
        return intro
    }
    
    private func isUpgraded(latestReceiptInfo: LatestReceiptInfo) -> Bool {
        var upgraded: Bool
        if latestReceiptInfo.is_upgraded == IsUpgraded.isTrue.rawValue {
            upgraded = true
        } else {
            upgraded = false
        }
        return upgraded
    }
    
    private func isAutoRenew(pendingRenewalInfo: PendingRenewalInfo) -> Bool {
        var autoRenewable: Bool
        if pendingRenewalInfo.auto_renew_status == IsAutoRenew.one.rawValue {
            autoRenewable = true
        } else {
            autoRenewable = false
        }
        return autoRenewable
    }
    
    private func isExpired(latestReceiptInfo: LatestReceiptInfo) -> Bool {
        var expired: Bool
        guard let expirationDate = Int64(latestReceiptInfo.expires_date_ms) else {return false}
        if currentDate > Date(milliseconds: expirationDate){
            expired = true
        } else {
            expired = false
        }
        return expired
    }
    
    private func expiresToday(latestReceiptInfo: LatestReceiptInfo) -> Bool {
        var expired: Bool
        guard let expirationDate = Int64(latestReceiptInfo.expires_date_ms) else {return false}
        if Date(milliseconds: expirationDate) == currentDate {
            expired = true
        } else {
            expired = false
        }
        return expired
    }
    
    private func gracePeriodWillExpired(pendingRenewalInfo: PendingRenewalInfo) -> Bool {
        guard let expirationDate = Int64(pendingRenewalInfo.grace_period_expires_date_ms ?? "") else {return false}
        var expired: Bool
        let almostExpired = Calendar.current.date(byAdding: .day, value: -7, to: Date(milliseconds: expirationDate))!
        if currentDate >= almostExpired {
            expired = true
        } else {
            expired = false
        }
        return expired
    }
    
    private func gracePeriodExpired(pendingRenewalInfo: PendingRenewalInfo) -> Bool {
        var expired: Bool
        guard let expirationDate = Int64(pendingRenewalInfo.grace_period_expires_date_ms ?? "") else {return false}
        if Date(milliseconds: expirationDate) >= currentDate {
            expired = true
        } else {
            expired = false
        }
        return expired
    }
    
    private func expirationLogic(_
                                 req: Request,
                                 latestReceiptInfo: LatestReceiptInfo,
                                 pendingRenewalInfo: PendingRenewalInfo
    ) throws -> EventLoopFuture<HTTPStatus> {
        if gracePeriodWillExpired(pendingRenewalInfo: pendingRenewalInfo) {
            guard let expirationDate = Int64(latestReceiptInfo.expires_date_ms) else {throw Abort(.noContent)}
            let df = DateFormatter()
            let expire = df.getFormattedDate(currentFormat: DateFormats.eighth.rawValue, newFormat: DateFormats.sixth.rawValue, date: Date(milliseconds: expirationDate))
            return req.apns.send(
                .init(title: APNNotifications.thankYouSubscribe.rawValue, subtitle: "\(APNNotifications.expiresOn.rawValue) \(expire).", body: APNNotifications.turnOnAutoRenew.rawValue),
                to: APNTokenData.shared.token
            ).transform(to: HTTPStatus.ok)
        } else if expiresToday(latestReceiptInfo: latestReceiptInfo) {
            return req.apns.send(
                .init(title: APNNotifications.subscriptionStatus.rawValue, subtitle: APNNotifications.expiresTodaySubtitle.rawValue, body: APNNotifications.expiresTodayBody.rawValue),
                to: APNTokenData.shared.token
            ).transform(to: HTTPStatus.ok)
        } else if isExpired(latestReceiptInfo: latestReceiptInfo) {
            guard let id = UUID(uuidString: OrderData.shared.orderID) else {throw Abort(.notFound)}
            return req.orders
                .set(\.$isSubscribed, to: false, for: id)
                .transform(to: HTTPStatus.ok)
        }
        return req.eventLoop.future(.ok)
    }
    
    private func cancellationLogic(_
                                   req: Request,
                                   latestReceiptInfo: LatestReceiptInfo
    ) throws -> EventLoopFuture<HTTPStatus> {
        if cancellationReason(latestReceiptInfo: latestReceiptInfo) == CancellationReason.reasonOne.rawValue {
            return req.apns.send(
                .init(title: APNNotifications.cancelled.rawValue, subtitle: APNNotifications.cancelledSubtitle.rawValue, body: APNNotifications.cancelledBody.rawValue),
                to:  APNTokenData.shared.token
            ).transform(to: HTTPStatus.ok)
        } else {
            //User Is Refunded because of a potential issue in the app set the User Subscription State accordingly and message the user appologizing and asking for feed back
            return req.apns.send(
                .init(title: APNNotifications.cancelled.rawValue, subtitle: APNNotifications.cancelledSubtitle.rawValue, body: APNNotifications.cancelledIssueBody.rawValue),
                to:  APNTokenData.shared.token
            ).transform(to: HTTPStatus.ok)
        }
    }
    
    private func turnAutoRenewOn(_
                                 req: Request,
                                 pendingRenewalInfo: PendingRenewalInfo
    ) throws -> EventLoopFuture<HTTPStatus> {
        return req.apns.send(
            .init(title: APNNotifications.autoRenewOff.rawValue, subtitle: APNNotifications.turnOnAutoRenew.rawValue, body: APNNotifications.turnAutoOnBody.rawValue),
            to: APNTokenData.shared.token
        ).transform(to: HTTPStatus.ok)
    }
    
    private func sendUpgradeThankYou(_
                                     req: Request,
                                     latestReceiptInfo: LatestReceiptInfo
    ) throws -> EventLoopFuture<HTTPStatus> {
        return req.apns.send(
            .init(title: APNNotifications.thankYouSubscribe.rawValue, subtitle: APNNotifications.upgradeSubtitle.rawValue),
            to: APNTokenData.shared.token
        ).transform(to: HTTPStatus.ok)
    }
    
    
    private func handleTrialSubscriptionStatus(_
                                               req: Request,
                                               latestReceiptInfo: LatestReceiptInfo
    ) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = UUID(uuidString: OrderData.shared.orderID) else {throw Abort(.notFound)}
        if latestReceiptInfo.is_in_intro_offer_period == "true" {
            return req.apns.send(
                .init(title: APNNotifications.subscriptionStatus.rawValue, subtitle: APNNotifications.introOfferPeriod.rawValue, body: APNNotifications.introOfferPeriodBody.rawValue)
                , to: APNTokenData.shared.token
            ).map { (res) in
                return req.orders
                    .set(\.$isSubscribed, to: true, for: id)
                    .transform(to: HTTPStatus.ok)
            }.transform(to: HTTPStatus.ok)
        } else if latestReceiptInfo.is_in_intro_offer_period == "false" {
            return req.apns.send(
                .init(title: APNNotifications.subscriptionStatus.rawValue, subtitle: APNNotifications.introOfferExpired.rawValue, body: APNNotifications.introOfferExpiredBody.rawValue)
                , to: APNTokenData.shared.token
            ).map { (res) in
                return req.orders
                    .set(\.$isSubscribed, to: false, for: id)
                    .transform(to: HTTPStatus.ok)
            }.transform(to: HTTPStatus.ok)
        } else if latestReceiptInfo.is_trial_period == "true" {
            return req.apns.send(
                .init(title: APNNotifications.subscriptionStatus.rawValue, subtitle: APNNotifications.trialPeriod.rawValue, body: APNNotifications.trialPeriodBody.rawValue)
                , to: APNTokenData.shared.token
            ).map { (res) in
                return req.orders
                    .set(\.$isSubscribed, to: true, for: id)
                    .transform(to: HTTPStatus.ok)
            }.transform(to: HTTPStatus.ok)
        } else if latestReceiptInfo.is_trial_period == "false" {
            return req.apns.send(
                .init(title: APNNotifications.subscriptionStatus.rawValue, subtitle: APNNotifications.trialPeriodExpired.rawValue, body: APNNotifications.trialPeriodExpiredBody.rawValue)
                , to: APNTokenData.shared.token
            ).map { (res) in
                return req.orders
                    .set(\.$isSubscribed, to: false, for: id)
                    .transform(to: HTTPStatus.ok)
            }.transform(to: HTTPStatus.ok)
        }
        return req.eventLoop.future(.ok)
    }
    
    private func handleUsersSubscriptionStatus(_
                                               req: Request,
                                               latestReceiptInfo:
                                               LatestReceiptInfo
    ) throws -> EventLoopFuture<HTTPStatus> {
        //We can send a notification for thanking users after upgrade or downgrade
        guard let id = UUID(uuidString: OrderData.shared.orderID) else {throw Abort(.notFound)}
        switch latestReceiptInfo.product_id {
        case weeklyProductID:
            print("OUR PRODUCT ID \(latestReceiptInfo.product_id)")
            return req.apns.send(
                .init(title: APNNotifications.subscriptionStatus.rawValue, subtitle: APNNotifications.weeklyProductSubtitle.rawValue, body: APNNotifications.weeklyProductBody.rawValue)
                , to: APNTokenData.shared.token
            ).map { (res) in
                return req.orders
                    .set(\.$productName, to: latestReceiptInfo.product_id, for: id)
            }.transform(to: HTTPStatus.ok)
        case monthlyProductID:
            print("OUR PRODUCT ID \(latestReceiptInfo.product_id)")
            return req.apns.send(
                .init(title: APNNotifications.subscriptionStatus.rawValue, subtitle: APNNotifications.monthlyProductSubtitle.rawValue, body: APNNotifications.monthlyProductBody.rawValue)
                , to: APNTokenData.shared.token
            ).transform(to: HTTPStatus.ok)
        case yearlyProductID:
            print("OUR PRODUCT ID \(latestReceiptInfo.product_id)")
            return req.apns.send(
                .init(title: APNNotifications.subscriptionStatus.rawValue, subtitle: APNNotifications.yearlyProductSubtitle.rawValue, body: APNNotifications.yearlyProductBody.rawValue)
                , to: APNTokenData.shared.token
            ).map { (res) in
                return req.orders
                    .set(\.$productName, to: latestReceiptInfo.product_id, for: id)
            }.transform(to: HTTPStatus.ok)
        default:
            print("WE DO NOT HAVE A PRODUCT ID BECAUSE WE HAVE NOT SUBSCRIBED")
            return req.apns.send(
                .init(title: APNNotifications.notSubscribed.rawValue, subtitle: APNNotifications.notSubscribedSubtitle.rawValue, body: APNNotifications.notSubscribedBody.rawValue)
                , to: APNTokenData.shared.token
            ).map { (res) in
                return req.orders
                    .set(\.$productName, to: latestReceiptInfo.product_id, for: id)
            }.transform(to: HTTPStatus.ok)
        }
    }
    
    //Here is our entitlement engine that sends our user notification along with their user status
    public func processReceipt(
        req: Request,
        latestReceiptInfo: LatestReceiptInfo,
        pendingRenewalInfo: PendingRenewalInfo
    ) -> EventLoopFuture<HTTPStatus> {
        if !latestReceiptInfo.product_id.isEmpty {
            do {
                if gracePeriodWillExpired(pendingRenewalInfo: pendingRenewalInfo) {
                    return try turnAutoRenewOn(req, pendingRenewalInfo: pendingRenewalInfo)
                } else if expiresToday(latestReceiptInfo: latestReceiptInfo) {
                    return try expirationLogic(req, latestReceiptInfo: latestReceiptInfo, pendingRenewalInfo: pendingRenewalInfo)
                } else if isExpired(latestReceiptInfo: latestReceiptInfo) {
                    return try expirationLogic(req, latestReceiptInfo: latestReceiptInfo, pendingRenewalInfo: pendingRenewalInfo)
                } else if isCancelled(latestReceiptInfo: latestReceiptInfo) {
                    return try handleUsersSubscriptionStatus(req, latestReceiptInfo: latestReceiptInfo)
                } else if isUpgraded(latestReceiptInfo: latestReceiptInfo) {
                    return try sendUpgradeThankYou(req, latestReceiptInfo: latestReceiptInfo)
                } else if !cancellationReason(latestReceiptInfo: latestReceiptInfo).isEmpty {
                    return try cancellationLogic(req, latestReceiptInfo: latestReceiptInfo)
                } else if isTrial(latestReceiptInfo: latestReceiptInfo) {
                    return try handleTrialSubscriptionStatus(req, latestReceiptInfo: latestReceiptInfo)
                } else if isIntroOffer(latestReceiptInfo: latestReceiptInfo) {
                    return try handleTrialSubscriptionStatus(req, latestReceiptInfo: latestReceiptInfo)
                }
            } catch {
                print("We have an error processing the latest receipt", error)
            }
        } else {
            return req.apns.send(
                .init(title: APNNotifications.notSubscribed.rawValue, subtitle: APNNotifications.notSubscribedSubtitle.rawValue, body: APNNotifications.notSubscribedBody.rawValue)
                , to: APNTokenData.shared.token
            ).transform(to: HTTPStatus.ok)
        }
        return req.eventLoop.future(.ok)
    }
}

extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension DateFormatter {
    func getFormattedDate(currentFormat: String, newFormat: String, date: Date) -> String {
        let dateFormatter = self
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        
        dateFormatter.dateFormat = currentFormat
        //
        //    let oldDate = dateFormatter.date(from: dateString)
        
        let converToNewFormat = self
        converToNewFormat.dateFormat = newFormat
        
        return converToNewFormat.string(from: date)
    }
}
