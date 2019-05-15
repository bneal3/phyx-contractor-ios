//
//  ApiService.swift
//  Camp
//
//  Created by sonnaris on 8/22/18.
//  Copyright © 2018 sonnaris. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Realm
import RealmSwift

class ApiService {
    
    private static var sharedApiService: ApiService = {
        let apiService = ApiService()
        return apiService
    }()
    
    /*
     **  User registration/login and forgot password apis
     */
    
    func completeLogin(response: Response, password: String, onSuccess success: @escaping(_ result: Contractor) -> Void, onFailure failure: @escaping(_ result: Any) -> Void) {
        
        guard response.status == 200 else {
            failure(response)
            return
        }
        
        var auth = "x-auth"
        if _env == Environment.production {
            auth = "X-Auth"
        }
        guard let token = response.headers[auth] as? String else {
            failure(response)
            return
        }
        
        let contractor = Contractor(contractorData: response.object)
        ContractorData.shared().setContractor(token: token, contractor: contractor)
        ContractorData.shared().setPassword(password: password)
        
        RealmService.shared.setDefaultRealmForUser(id: contractor.id)
        
        success(contractor)
    }
    
    func loginContractor(identifier: String, password: String, onSuccess success: @escaping(_ result: Contractor) -> Void, onFailure failure: @escaping(_ result: Any) -> Void) {
        
        let parameters : Parameters = [
            "identifier": identifier,
            "password": password
        ]
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.post
        request.path = "/contractors/login"
        request.parameters = parameters
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            self.completeLogin(response: response, password: password, onSuccess: success, onFailure: failure)
            
        }, onError: failure)
    }
    
    func registerContractor(phone: String, password: String, first: String, last: String, address: String, birth: Int64, bio: String, onSuccess success: @escaping(_ result: Contractor) -> Void, onFailure failure: @escaping(_ result: Any) -> Void) {
        
        let parameters : Parameters = [
            "identifiers": [
                [
                    "method": "phone",
                    "value": phone
                ]
            ],
            "password": password,
            "first": first,
            "last": last,
            "address": address,
            "bio": bio,
            "birthday": birth
        ]
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.post
        request.path = "/contractors"
        request.parameters = parameters
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            UserData.shared().setTutorial()
            self.completeLogin(response: response, password: password, onSuccess: success, onFailure: failure)
            
        }, onError: failure)
    }
    
    func sendCode(phone: String, onSuccess success: @escaping(_ result: Response) -> Void, onFailure failure: @escaping(_ result: Any) -> Void) {
        
        let parameters : Parameters = [
            "phone": phone
        ]

        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.post
        request.path = "/contractors/verify/phone/send"
        request.parameters = parameters
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            success(response)

        }, onError: failure)
    }
    
    func verifyCode(code: String, phone: String, lock: Bool?, onSuccess success: @escaping(_ result: Response) -> Void, onFailure failure: @escaping(_ result: Any) -> Void) {
        
        let parameters: Parameters = [
            "code": code,
            "phone": phone,
            "lock": lock
        ]
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.post
        request.path = "/contractors/verify/phone/receive"
        request.parameters = parameters
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            success(response)
            
        }, onError: failure)
        
    }
    
    // Profile
    
    func changePassword(oldPassword: String, newPassword: String, onSuccess success: @escaping(_ result: Response) -> Void, onFailure failure: @escaping(_ error: Any) -> Void) {
        
        let parameters = [
            "old": oldPassword,
            "new": newPassword
        ]
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.patch
        request.path = "/contractors/me/password"
        request.parameters = parameters
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            success(response)
            
        }, onError: failure)
        
    }
    
    func forgotPassword(newPassword: String, lock: String, onSuccess success: @escaping(_ result: Contractor) -> Void, onFailure failure: @escaping(_ error: Any) -> Void) {
        
        let parameters = [
            "password": newPassword
        ]
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.delete
        request.path = "/contractors/lock"
        request.parameters = parameters
        request.headers = ["x-lock": lock]
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            let contractor = Contractor(contractorData: response.object)
            success(contractor)
            
        }, onError: failure)
        
    }
    
    func updateProfile(phone: String, first: String, last: String, address: String, bio: String, avatar: String, video: String, onSuccess success: @escaping(_ result: Contractor) -> Void, onFailure failure: @escaping(_ error: Any) -> Void) {
        
        let parameters = [
            "phone": phone,
            "first": first,
            "last": last,
            "address": address,
            "bio": bio,
            "avatar": avatar,
            "video": video
        ]
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.patch
        request.path = "/contractors/me/profile"
        request.parameters = parameters
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            // FLOW: Update UserDefaults
            if response.object.count > 0 {
                
                let contractor = Contractor(contractorData: response.object)
                ContractorData.shared().setContractor(token: ContractorData.shared().getToken()!, contractor: contractor)
                success(contractor)
                
            } else {
                
                failure(response)
                
            }
            
        }, onError: failure)
        
    }
    
    func submitDocuments(documents: [String], onSuccess success: @escaping(_ result: Response) -> Void, onFailure failure: @escaping(_ error: Any) -> Void) {
        
        let parameters = [
            "documents": documents
        ]
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.post
        request.path = "/contractors/documents"
        request.parameters = parameters
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            success(response)
            
        }, onError: failure)
        
    }
    
    func submitBank(account: String, routing: String, onSuccess success: @escaping(_ result: Response) -> Void, onFailure failure: @escaping(_ error: Any) -> Void) {
        
        let parameters = [
            "account": account,
            "routing": routing
        ]
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.post
        request.path = "/contractors/bank"
        request.parameters = parameters
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            success(response)
            
        }, onError: failure)
        
    }
    
    // Appointments
    
    func getAppointment(id: String, onSuccess success: @escaping(_ result: Appointment) -> Void, onFailure failure: @escaping(_ error: Any) -> Void) {
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.get
        request.path = "/appointments/id/" + id
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            let appointment = Appointment(appointmentData: response.object)
            
            RealmService.shared.createIfNotExists(appointment)
            PNWrapper.shared().client.subscribeToChannels([appointment.id], withPresence: false)
            
            success(appointment)
            
        }, onError: failure)
        
    }
    
    func getAppointments(available: Bool, onSuccess success: @escaping(_ result: [Appointment]) -> Void, onFailure failure: @escaping(_ error: Any) -> Void) {
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.get
        request.path = "/appointments/contractor?available=" + String(available)
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            if let json = response.object["appointments"] as? [[String: Any]] {
                
                var appointments = [Appointment]()
                for appointmentData in json {
                    let appointment = Appointment(appointmentData: appointmentData)
                    
                    RealmService.shared.createIfNotExists(appointment)
                    PNWrapper.shared().client.subscribeToChannels([appointment.id], withPresence: false)
                    
                    appointments.append(appointment)
                }
                
                success(appointments)
                
            } else {
                
                failure(response)
                
            }
            
        }, onError: failure)
        
    }
    
    func patchAppointment(id: String, status: Int, rating: Int?, onSuccess success: @escaping(_ result: Appointment) -> Void, onFailure failure: @escaping(_ error: Any) -> Void) {
        
        let parameters = [
            "status": status,
            "rating": rating
        ]
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.patch
        request.path = "/appointments/id/" + id + "/contractor"
        request.parameters = parameters
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            let appointment = Appointment(appointmentData: response.object)
            success(appointment)
            
        }, onError: failure)
        
    }
    
    // Users
    
    func getUsers(path: String, onSuccess success: @escaping(_ result: [User]) -> Void, onFailure failure: @escaping(_ result: Any) -> Void) {
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.get
        request.path = "/users?" + path
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            if let json = response.object["users"] as? [[String: Any]] {
                
                var users = [User]()
                for userData in json {
                    let user = User(userData: userData)
                    users.append(user)
                }
                
                success(users)
                
            } else {
                
                failure(response)
                
            }
            
        }, onError: failure)
        
    }
    
    func getUser(id: String, onSuccess success: @escaping(_ result: User) -> Void, onFailure failure: @escaping(_ result: Any) -> Void) {
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.get
        request.path = "/users/id/" + id
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            if response.object.count > 0 {
                
                let user = User(userData: response.object)
                
                RealmService.shared.createIfNotExists(user)
                
                success(user)
                
            } else {
                
                failure(response)
                
            }
            
        }, onError: failure)
        
    }
    
    func getAppointment(id: String, onSuccess success: @escaping(_ result: User) -> Void, onFailure failure: @escaping(_ result: Any) -> Void) {
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.get
        request.path = "/appointments/id/" + id
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            
            if response.object.count > 0 {
                
                let user = User(userData: response.object)
                success(user)
                
            } else {
                
                failure(response)
                
            }
            
        }, onError: failure)
        
    }
    
    // Settings
    
    func sendFeedback(subject: String, feedback: String, onSuccess success: @escaping (_ result: Response) -> Void, onFailure failure: @escaping (_ error: Any) -> Void) {

        let parameters = [
            "subject": subject,
            "body": feedback
        ]
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.post
        request.path = "/users/feedback"
        request.parameters = parameters
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
            success(response)
            
        }, onError: failure)

    }
    
    func logout(onSuccess success: @escaping (_ result: Response) -> Void, onFailure failure: @escaping (_ error: Any) -> Void) {
        
        var request: HTTPRequest = HTTPRequest()
        request.method = HTTPMethod.delete
        request.path = "/contractors/me/token"
        
        REQWrapper.shared.send(request: request, onSuccess: { response in
    
            success(response)
            
        }, onError: failure)
        
    }
    
    /* Users api end */
    
    
    class func shared() -> ApiService {
        return sharedApiService
    }
    
}
