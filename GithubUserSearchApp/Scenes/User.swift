//
//  User.swift
//  GithubUserSearchApp
//
//  Created by Abdullah Nur on 20.01.2024.
//

import Foundation

struct User: Codable {
    let login: String
    let avatar_url: String
    let created_at: String
    let location: String?
}
