//
//  ContractorApp.swift
//  Phyx Contractor
//
//  Created by Benjamin Neal on 4/9/19.
//  Copyright © 2019 Phyx, Inc. All rights reserved.
//

import Foundation

import OneSignal
import RealmSwift

class ContractorData {
    
    private static var sharedData: ContractorData = {
        let data = ContractorData()
        return data
    }()
    
    class func shared() -> ContractorData {
        return sharedData
    }
    
    // Set
    public func setContractor(token: String, contractor: Contractor) {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(true, forKey: "contractor_login")
        
        userDefaults.set(contractor.id, forKey: "contractor_id")
        userDefaults.set(token, forKey: "contractor_token")
        
        userDefaults.set(contractor.phone, forKey: "contractor_phone")
        userDefaults.set(contractor.paymentId, forKey: "contractor_paymentId")
        
        userDefaults.set(contractor.first, forKey: "contractor_first")
        userDefaults.set(contractor.last, forKey: "contractor_last")
        userDefaults.set(contractor.address, forKey: "contractor_address")
        userDefaults.set(contractor.birthday, forKey: "contractor_birthday")
        
        userDefaults.set(contractor.bio, forKey: "contractor_bio")
        if let avatar = contractor.avatar {
            userDefaults.set(avatar, forKey: "contractor_avatar")
        }
        if let video = contractor.video {
            userDefaults.set(video, forKey: "contractor_video")
        }
        userDefaults.set(Array(contractor.services), forKey: "contractor_services")
        
        userDefaults.set(contractor.submitted, forKey: "contractor_submitted")
        userDefaults.set(contractor.approved, forKey: "contractor_approved")
        
        userDefaults.set(contractor.device, forKey: "contractor_device")
        
        userDefaults.synchronize()
    }
    
    public func setPassword(password: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(password, forKey: "contractor_password")
        userDefaults.synchronize()
    }
    
    public func setPhone(phone: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(phone, forKey: "contractor_phone")
        userDefaults.synchronize()
    }
    
    public func setPaymentId(paymentId: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(paymentId, forKey: "contractor_paymentId")
        userDefaults.synchronize()
    }
    
    public func setFirst(first: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(first, forKey: "contractor_first")
        userDefaults.synchronize()
    }
    
    public func setLast(last: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(last, forKey: "contractor_last")
        userDefaults.synchronize()
    }

    public func setBirthday(birthday: Int64) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(birthday, forKey: "contractor_birthday")
        userDefaults.synchronize()
    }
    
    public func setAvatar(avatar: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(avatar, forKey: "contractor_avatar")
        userDefaults.synchronize()
    }
    
    public func setVideo(video: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(video, forKey: "contractor_video")
        userDefaults.synchronize()
    }
    
    public func setSubmitted(submitted: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(submitted, forKey: "contractor_submitted")
        userDefaults.synchronize()
    }
    
    public func setApproved(approved: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(approved, forKey: "contractor_approved")
        userDefaults.synchronize()
    }
    
    public func setDevice(device: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(device, forKey: "contractor_device")
        userDefaults.synchronize()
    }
    
    // Get
    public func getContractor() -> Contractor {
        var contractorData: [String: Any] = [:]
        
        let userDefaults = UserDefaults.standard
        let id = userDefaults.object(forKey: "contractor_id")
        contractorData["_id"] = id
        
        var identifiers: [[String: Any]] = []
        let phone = userDefaults.object(forKey: "contractor_phone")
        identifiers.append(["method": "phone", "value": phone])
        if let paymentId = userDefaults.object(forKey: "contractor_paymentId") as? String {
            identifiers.append(["method": "paymentId", "value": paymentId])
        }
        contractorData["identifiers"] = identifiers
        
        var name: [String: Any] = [:]
        let first = userDefaults.object(forKey: "contractor_first") as! String
        name["first"] = first
        let last = userDefaults.object(forKey: "contractor_last") as! String
        name["last"] = last
        contractorData["name"] = name
        
        let address = userDefaults.object(forKey: "contractor_address") as! String
        contractorData["address"] = address
        let birthday = userDefaults.object(forKey: "contractor_birthday") as! Int64
        contractorData["birthday"] = birthday
        
        let bio = userDefaults.object(forKey: "contractor_bio") as! String
        contractorData["bio"] = bio
        var avatar = ""
        if let _avatar = userDefaults.object(forKey: "contractor_avatar") as? String {
            avatar = _avatar
        }
        contractorData["avatar"] = avatar
        var video = ""
        if let _video = userDefaults.object(forKey: "contractor_video") as? String {
            video = _video
        }
        contractorData["video"] = video
        let services = userDefaults.array(forKey: "contractor_services")
        contractorData["services"] = services

        let submitted = userDefaults.object(forKey: "contractor_submitted") as! Bool
        contractorData["submitted"] = submitted
        let approved = userDefaults.object(forKey: "contractor_approved") as! Bool
        contractorData["approved"] = approved
        
        var device = ""
        if let _device = userDefaults.object(forKey: "contractor_device") as? String {
            device = _device
        }
        contractorData["device"] = device
        
        let contractor = Contractor(contractorData: contractorData)
        return contractor
    }
    
    public func getId() -> String {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_id") as! String
    }
    
    public func isLogged() -> Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: "contractor_login")
    }
    
    public func getToken() -> String? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_token") as? String
    }
    
    public func getPhone() -> String {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_phone") as! String
    }
    
    public func getPaymentId() -> String? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_paymentId") as? String
    }
    
    public func getUserPassword() -> String? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_password") as? String
    }
    
    public func getFirstName() -> String {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_first") as! String
    }
    
    public func getLastName() -> String {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_last") as! String
    }
    
    public func getUserBirthday() -> Int64 {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_birthday") as! Int64
    }
    
    public func getAddress() -> String {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_address") as! String
    }

    public func getBio() -> String {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_bio") as! String
    }
    
    public func getAvatar() -> String? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_avatar") as? String
    }
    
    public func getVideo() -> String? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_video") as? String
    }
    
    public func getSubmitted() -> Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_submitted") as! Bool
    }
    
    public func getApproved() -> Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_approved") as! Bool
    }
    
    public func getDevice() -> String {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "contractor_device") as! String
    }
    
    // First time usage
    public func setFirstTimeUsage(screen: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(false, forKey: "contractor_first_time_\(screen)")
        userDefaults.synchronize()
    }
    
    public func isFirstTimeUsage(screen: String) -> Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: "contractor_first_time_\(screen)")
    }
    
    // Seen approved
    public func sawApproved(saw: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(saw, forKey: "contractor_saw_approved")
        userDefaults.synchronize()
    }
    
    public func hasSeenApproved() -> Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: "contractor_saw_approved")
    }
    
    // Logout
    public func logout() {
        
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "contractor_id")
        userDefaults.removeObject(forKey: "contractor_login")
        userDefaults.removeObject(forKey: "contractor_token")
        
        userDefaults.removeObject(forKey: "contractor_phone")
        
        userDefaults.removeObject(forKey: "contractor_password")
        userDefaults.removeObject(forKey: "contractor_birthday")
        
        userDefaults.removeObject(forKey: "contractor_first")
        userDefaults.removeObject(forKey: "contractor_last")
        userDefaults.removeObject(forKey: "contractor_avatar")
        userDefaults.removeObject(forKey: "contractor_bio")
        userDefaults.removeObject(forKey: "contractor_video")
        
        userDefaults.removeObject(forKey: "contractor_submitted")
        userDefaults.removeObject(forKey: "contractor_approved")
        
        userDefaults.removeObject(forKey: "contractor_services")
        userDefaults.removeObject(forKey: "contractor_device")
        
        userDefaults.removeObject(forKey: "contractor_saw_approved")
        
        userDefaults.removeObject(forKey: "contractor_first_time_leaderboards")
        userDefaults.removeObject(forKey: "contractor_first_time_chats")
        userDefaults.removeObject(forKey: "contractor_first_time_profile")
        
        userDefaults.synchronize()
    }
    
    func getPlayerId() -> String? {
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        
        if let userId = status.subscriptionStatus.userId {
            return userId
        }
        return nil
    }
}
