//
//  UserNetwork.swift
//  GithubUserSearchApp
//
//  Created by Abdullah Nur on 21.01.2024.
//

import Foundation

class UserNetwork{
    
    static let shared = UserNetwork()
    
    // login için bir kod register için başka bir kod gibi bu şekilde bir sürü açabiliriz bu yüzden burası var 
    
    func getUser(username: String, completion: @escaping (Result<User, Error>) -> Void) {
            let url = NetworkHelper.shared.baseURL + "users/" + username
            NetworkManager.shared.get(url: url, params: [:]) { result in
                switch result {
                case .success(let data):
                    do {
                        let user = try JSONDecoder().decode(User.self, from: data)
                        completion(.success(user))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    
}
