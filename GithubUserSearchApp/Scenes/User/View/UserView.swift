//
//  UserViewController.swift
//  GithubUserSearchApp
//
//  Created by Abdullah Nur on 20.01.2024.
//

import UIKit

class UserView: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var publicRepoCountLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var createdAccountDateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    private var userViewModel = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func getUserInfoButtonPressed(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty else {
            showAlert(message: "Lütfen kullanıcı adı giriniz.")
            return
        }
        
        userViewModel.getUserInfo(username: username) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.updateUI()
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.showAlert(message: "Kullanıcı bulunamadı.")
                }
            }
        }
        
        userViewModel.getUserLanguages(username: username) { result in
                    switch result {
                    case .success(let languages):
                        DispatchQueue.main.async {
                            self.showLanguages(languages)
                        }
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.showAlert(message: "Kullanıcı dilleri alınamadı.")
                        }
                    }
                }
        
    }
    
    private func showLanguages(_ languages: [String: Int]) {
            for (language, byteCount) in languages {
                print("\(language): \(byteCount)")
            }
        }
    
    
    
    
    private func updateUI() {
        usernameLabel.text = userViewModel.username
        publicRepoCountLabel.text = "\(userViewModel.publicRepoCount)"
        createdAccountDateLabel.text = userViewModel.createdAt
        locationLabel.text = userViewModel.location
        
        if let avatarURL = userViewModel.avatarURL {
            URLSession.shared.dataTask(with: avatarURL) { data, response, error in
                if let data = data {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.avatarImageView.image = image
                    }
                }
            }.resume()
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
