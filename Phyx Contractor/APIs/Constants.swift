//
//  Constants.swift
//  Camp
//
//  Created by sonnaris on 8/22/18.
//  Copyright © 2018 sonnaris. All rights reserved.
//

import UIKit

class Constants: NSObject {
    
    static let REALM_VERSION: UInt64 = 0
    
    static let OS_APP_ID = "9ea99bd6-ccd2-4fe1-9e09-b6099191583a"
    
    static let APP_STORE_LINK = ""
    
    struct ApplePay {
        static let MERCHANT_IDENTIFIER: String = "REPLACE_ME"
        static let COUNTRY_CODE: String = "US"
        static let CURRENCY_CODE: String = "USD"
    }
    
    struct Square {
        static let APPLICATION_ID: String  = "sq0idp-9QmMgskzZL9hKN9Kq7UNZQ"
    }
}


struct Style {
    static func setDefaults() {
        UINavigationBar.appearance().tintColor = Color.primaryAction
    }
}
