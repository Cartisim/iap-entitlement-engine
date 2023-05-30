//
//  File.swift
//  
//
//  Created by Cole M on 5/30/23.
//

import Foundation

enum CancellationReason: String {
    case reasonOne = "Cancelled for some reason, perhaps the purchase was an accident"
    case reasonTwo = "Cancelled because there was an issue or a perceived issue within your app"
}

enum CancellationInteger: String {
    case cancellationIntegerZero = "0"
    case cancellationIntegerOne = "1"
}

enum IsTrial: String {
    case isTrue = "true"
    case isFalse = "false"
}

enum IsIntroOffer: String {
    case isTrue = "true"
    case isFalse = "false"
}

enum IsUpgraded: String {
    case isTrue = "true"
    case isFalse = "false"
}

enum IsAutoRenew: String {
    case zero = "0"
    case one = "1"
}

enum APNNotifications: String {
    case thankYouSubscribe = "Thank you for subscribing"
    case expiresOn = "Your subscription will expire on:"
    case turnOnAutoRenew = "Please turn on auto renew for an uninterrupted experience!"
    case cancelled = "Cancelled Subscription"
    case cancelledSubtitle = "We are Sorry to See you go!"
    case cancelledBody = "Please feel free to subscribe at anytime! Thank you:- Cartisim"
    case cancelledIssueBody = "We are really sorry that you may have had technical trouble with Cartisim, please email us and let us know how we can improve. Thank you, Cartisim"
    case autoRenewOff = "Hey Auto Renew is Off"
    case turnAutoOnBody = "If you turn auto renew on you will enjoy uninterrupted experience, also If you upgrade you can save anywhere from $30 - $150 USD/year if you upgrade to an annual subscription. What a deal!"
    case upgradeSubtitle = "Congratulations! You just save a bunch of money upgrading your Subscription"
    case subscriptionStatus = "Subscription Satutus:"
    case weeklyProductSubtitle = "Weekly Subscription"
    case weeklyProductBody = "You have weekly subscription privileges, Upgrade to save some cash."
    case monthlyProductSubtitle = "Monthly Subscription"
    case monthlyProductBody = "You have monthly subscription privileges, Upgrade to save some cash."
    case yearlyProductSubtitle = "Yearly Subscription"
    case yearlyProductBody = "You have yearly subscription privileges, please enjoy 😁"
    case notSubscribed = "No Subscription"
    case notSubscribedSubtitle = "Hey, thanks for using Cartisim"
    case notSubscribedBody = "Enjoy the ultimate experience by subscribing"
    case expiresTodaySubtitle = "Your Subscription Will Expire Today"
    case expiresTodayBody = "Please turn on auto renew and make sure your payment method is valid in order to enjoy an uninterrupted experience."
    case newMessage = "New Message!"
    case introOfferPeriod = "Introductory Offer:"
    case introOfferPeriodBody = "Thank you for taking advatage of our intro offer!"
    case introOfferExpired = "Introductory Offer Expired:"
    case introOfferExpiredBody = "Thank you for taking advatage of our intro offer, in order to continue using Cartisim please subscribe. 😁"
    case trialPeriod = "Trial Period:"
    case trialPeriodBody = "Thank you for trying before your subscribe!"
    case trialPeriodExpired = "Trial Period Expired:"
    case trialPeriodExpiredBody = "Thank you for trying before your subscribe, in order to continue using Cartisim please subscribe. 😁"
}
