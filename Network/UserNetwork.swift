//
//  UserNetwork.swift
//  GithubUserSearchApp
//
//  Created by Abdullah Nur on 21.01.2024.
//

import Foundation
import Alamofire
import Charts

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
    
    func getUserRepos(username: String, completion: @escaping (Result<[String: Int], Error>) -> Void) {
        let url = "users/" + username + "/repos"

        NetworkManager.shared.get(url: url, headers: NetworkHelper.shared.headers(), params: [:]) { result in
            switch result {
            case .success(let data):
                do {
                    let repositories = try JSONDecoder().decode([Repository].self, from: data)

                    var languagesCount = [String: Int]()

                    let dispatchGroup = DispatchGroup()

                    for repo in repositories {
                        dispatchGroup.enter()

                        self.getRepositoryLanguages(owner: username, repoName: repo.name) { result in
                            defer {
                                dispatchGroup.leave()
                            }

                            switch result {
                            case .success(let repoLanguages):
                                for (language, byteCount) in repoLanguages {
                                    languagesCount[language] = (languagesCount[language] ?? 0) + byteCount
                                }
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        completion(.success(languagesCount))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func getRepositoryLanguages(owner: String, repoName: String, completion: @escaping (Result<[String: Int], Error>) -> Void) {
        let url = "repos/\(owner)/\(repoName)/languages"

        NetworkManager.shared.get(url: url, headers: NetworkHelper.shared.headers(), params: [:]) { result in
            switch result {
            case .success(let data):
                do {
                    let repoLanguages = try JSONDecoder().decode([String: Int].self, from: data)

                    completion(.success(repoLanguages))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}

