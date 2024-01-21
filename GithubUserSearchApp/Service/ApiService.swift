//
//  ApiService.swift
//  GithubUserSearchApp
//
//  Created by Abdullah Nur on 20.01.2024.
//

import Foundation

import Alamofire

class ApiService {
    
    static let shared = ApiService()

    private let baseURL = "https://api.github.com/users/"

    func getUserInfo(username: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = baseURL + username
        AF.request(url)
            .responseDecodable(of: User.self) { response in
                switch response.result {
                case .success(let user):
                    completion(.success(user))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

