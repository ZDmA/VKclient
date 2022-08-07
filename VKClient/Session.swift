//
//  Session.swift
//  VK
//
//  Created by Дмитрий on 23.02.2022.
//

import Foundation

class Session {
    static let shared = Session()
    var name: String = ""
    var token: String = ""

    private init() {}
}
