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
        if let rawDate = user?.created_at {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            
            if let date = dateFormatter.date(from: rawDate) {
                dateFormatter.dateFormat = "dd MMMM yyyy"
                return dateFormatter.string(from: date)
            }
        }
        return ""
    }
    
    var location: String {
        return user?.location ?? ""
    }
    
    var avatarURL: URL? {
        return URL(string: user?.avatar_url ?? "")
    }
    
    
}

