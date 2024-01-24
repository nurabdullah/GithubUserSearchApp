//
//  UserViewModel.swift
//  GithubUserSearchApp
//
//  Created by Abdullah Nur on 20.01.2024.
//

import Foundation

class UserViewModel {
    
    private var user: User?
    private var repos: [Repo]?

       var repoNames: [String] {
           return repos?.map { $0.name } ?? []
       }

 
    func getUserInfo(username: String, completion: @escaping (Result<Void, Error>) -> Void) {
            UserNetwork.shared.getUser(username: username) { [weak self] result in
                switch result {
                case .success(let user):
                    self?.user = user
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    func getUserRepos(username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        UserNetwork.shared.getUserRepos(username: username) { [weak self] result in
            switch result {
            case .success(let repos):
                self?.repos = repos
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    var avatarURL: URL? {
        return URL(string: user?.avatar_url ?? "")
    }
    
    var username: String {
        return user?.login ?? ""
    }
    var publicRepoCount: Int {
        return user?.public_repos ?? 0
    }
    
    var name: String {
        return repos?.first?.name ?? ""
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
    
}

