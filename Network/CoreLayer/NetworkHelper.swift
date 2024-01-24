//
//  NetworkHelper.swift
//  GithubUserSearchApp
//
//  Created by Abdullah Nur on 21.01.2024.
//

import Foundation
import Alamofire


class NetworkHelper{
    
    static let shared = NetworkHelper()
    
    var baseURL = "https://api.github.com/"
    var token = "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"
    
    func headers() -> [String: String] {
        ["Authorization": "Bearer \(token)"]
    }
    
}
