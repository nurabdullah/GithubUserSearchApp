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
    
    func getUserRepos(username: String, completion: @escaping (Result<[String: Int], Error>) -> Void) {
        // Kullanıcının reposunu çekmek için URL oluşturuluyor. // endpoint
        let url = "users/" + username + "/repos"

        // NetworkManager sınıfı aracılığıyla HTTP GET isteği yapılıyor.
        NetworkManager.shared.get(url: url, headers: NetworkHelper.shared.headers(), params: [:]) { result in
            switch result {
            case .success(let data):
                do {
                    // Alınan veri [Repository] tipine çevriliyor.
                    let repositories = try JSONDecoder().decode([Repository].self, from: data)

                    // Her repo için toplam dil sayısını tutacak sözlük oluşturuluyor.
                    var languagesCount = [String: Int]()

                    // Asenkron işlemleri koordine etmek için DispatchGroup oluşturuluyor.
                    let dispatchGroup = DispatchGroup()

                    // Her bir repo için ayrı bir asenkron işlem başlatılıyor.
                    for repo in repositories {
                        dispatchGroup.enter()

                        // Her bir repo için dil bilgilerini almak için getRepositoryLanguages fonksiyonu çağrılıyor.
                        self.getRepositoryLanguages(owner: username, repoName: repo.name) { result in
                            defer {
                                // Asenkron işlem tamamlandığında DispatchGroup'tan çıkış yapılıyor.
                                dispatchGroup.leave()
                            }

                            switch result {
                            case .success(let repoLanguages):
                                // Alınan dil bilgileri, toplam dil sayısını tutan sözlüğe ekleniyor.
                                for (language, byteCount) in repoLanguages {
                                    languagesCount[language] = (languagesCount[language] ?? 0) + byteCount
                                }
                            case .failure(let error):
                                // Hata durumunda ana fonksiyonun completion closure'ı çağrılıyor.
                                completion(.failure(error))
                            }
                        }
                    }

                    // Tüm asenkron işlemler tamamlandığında çalışacak blok.
                    dispatchGroup.notify(queue: .main) {
                        // Toplanan dil bilgileri success case'inde completion closure'ı çağırarak döndürülüyor.
                        completion(.success(languagesCount))
                    }
                } catch {
                    // JSON çözme veya diğer hatalar durumunda completion closure'ı çağrılıyor.
                    completion(.failure(error))
                }
            case .failure(let error):
                // Network hatası durumunda completion closure'ı çağrılıyor.
                completion(.failure(error))
            }
        }
    }

    private func getRepositoryLanguages(owner: String, repoName: String, completion: @escaping (Result<[String: Int], Error>) -> Void) {
        // Belirli bir repo için dil bilgilerini çekmek için URL oluşturuluyor.
        let url = "repos/\(owner)/\(repoName)/languages"

        // NetworkManager sınıfı aracılığıyla HTTP GET isteği yapılıyor.
        NetworkManager.shared.get(url: url, headers: NetworkHelper.shared.headers(), params: [:]) { result in
            switch result {
            case .success(let data):
                do {
                    // Alınan veri [String: Int] tipine çevriliyor.
                    let repoLanguages = try JSONDecoder().decode([String: Int].self, from: data)

                    // Başarılı durumda completion closure'ı çağrılarak dil bilgileri döndürülüyor.
                    completion(.success(repoLanguages))
                } catch {
                    // JSON çözme veya diğer hatalar durumunda completion closure'ı çağrılıyor.
                    completion(.failure(error))
                }
            case .failure(let error):
                // Network hatası durumunda completion closure'ı çağrılıyor.
                completion(.failure(error))
            }
        }
    }

}

