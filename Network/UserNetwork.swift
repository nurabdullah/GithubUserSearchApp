//
//  UserNetwork.swift
//  GithubUserSearchApp
//
//  Created by Abdullah Nur on 21.01.2024.
//

import Foundation
import Alamofire

class UserNetwork {
    static let shared = UserNetwork()

    func getUser(username: String, completion: @escaping (Result<User, Error>) -> Void) {
        NetworkManager.shared.get(url: "users/" + username, headers: NetworkHelper.shared.headers(), params: [:]) { result in
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
