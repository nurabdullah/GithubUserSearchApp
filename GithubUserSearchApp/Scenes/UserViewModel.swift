//
//  UserViewModel.swift
//  GithubUserSearchApp
//
//  Created by Abdullah Nur on 20.01.2024.
//

import Foundation

class UserViewModel {
    private var user: User?

    func getUserInfo(username: String, completion: @escaping (Result<User, Error>) -> Void) {
        ApiService.shared.getUserInfo(username: username) { [weak self] result in
            switch result {
            case .success(let user):
                self?.user = user
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    var username: String {
        return user?.login ?? ""
    }
    var publicRepoCount: Int {
        return user?.public_repos ?? 0
    }

    var createdAt: String {
        return "Joined: \(user?.created_at ?? "")"
    }

    var location: String {
        return "Location: \(user?.location ?? "Unknown")"
    }

    var avatarURL: URL? {
        return URL(string: user?.avatar_url ?? "")
    }
    
    
}
    
