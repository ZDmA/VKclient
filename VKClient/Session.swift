//
//  Session.swift
//  VK
//
//  Created by Дмитрий on 23.02.2022.
//

import Foundation
import Alamofire

class VKSession {
    static let shared = VKSession()
    var client_id: String = "51409525"
    var token: String = ""

    private init() {}
}



