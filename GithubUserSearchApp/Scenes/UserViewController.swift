//
//  UserViewController.swift
//  GithubUserSearchApp
//
//  Created by Abdullah Nur on 20.01.2024.
//

import UIKit

class UserViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    private var userViewModel = UserViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func getUserInfoButtonPressed(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty else {
            showAlert(message: "Please enter a username.")
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
                    self?.showAlert(message: "Failed to fetch user information.")
                }
            }
        }
    }

    private func updateUI() {
        usernameLabel.text = "Username: \(userViewModel.username)"
        createdAtLabel.text = userViewModel.createdAt
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

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

