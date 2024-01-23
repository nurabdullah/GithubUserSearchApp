//
//  NetworkManager.swift
//  GithubUserSearchApp
//
//  Created by Abdullah Nur on 21.01.2024.
//

import Alamofire

class NetworkManager{
    
    static let shared = NetworkManager()
    
    func get(url: String, params: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) {
            AF.request(NetworkHelper.shared.baseURL + url, method: .get, parameters: params)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        if let data = response.data {
                            completion(.success(data))
                        } else {
                            completion(.failure(NSError(domain: "NetworkManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Veri alınamadı"])))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
        }
     
    
    
//    func post (url: String, params: [String: Any], complete: ()->()){
//        AF.request(url, method: .post , parameters: params)
//    }
    
}
