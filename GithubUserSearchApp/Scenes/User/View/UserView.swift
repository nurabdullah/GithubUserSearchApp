//
//  UserViewController.swift
//  GithubUserSearchApp
//
//  Created by Abdullah Nur on 20.01.2024.
//

import UIKit
import Charts

class UserView: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var publicRepoCountLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var createdAccountDateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var pieChartView: PieChartView!
    
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
        showTopLanguagesWithPercentage(languages)
    }


    
//    private func showTopLanguagesWithPercentage(_ languages: [String: Int], topCount: Int = 5) {
//        let sortedLanguages = languages.sorted { $0.value > $1.value }.prefix(topCount)
//        let totalByteCount = languages.values.reduce(0, +)
//        for (dil, byteSayisi) in sortedLanguages {
//            let yuzde = Double(byteSayisi) / Double(totalByteCount) * 100
//            print("\(dil): \(String(format: "%.2f", yuzde))%")
//        }
//    }
    
    private func showTopLanguagesWithPercentage(_ languages: [String: Int], topCount: Int = 5) {
           var entries: [PieChartDataEntry] = []

           let sortedLanguages = languages.sorted { $0.value > $1.value }.prefix(topCount)
           let totalByteCount = languages.values.reduce(0, +)

           for (language, byteCount) in sortedLanguages {
               let percentage = Double(byteCount) / Double(totalByteCount) * 100
               entries.append(PieChartDataEntry(value: percentage, label: language))
           }

           updatePieChart(entries: entries)
       }

//       private func updatePieChart(entries: [PieChartDataEntry]) {
//           let dataSet = PieChartDataSet(entries: entries, label: "Languages")
//           dataSet.colors = ChartColorTemplates.material()
//
//           let data = PieChartData(dataSet: dataSet)
//           pieChartView.data = data
//           pieChartView.notifyDataSetChanged()
//       }
    
    private func updatePieChart(entries: [PieChartDataEntry]) {
        var dataSet: PieChartDataSet

        if entries.isEmpty {
            // If entries are empty, add a default entry to display in the chart
            dataSet = PieChartDataSet(entries: [PieChartDataEntry(value: 100, label: "No Data")], label: "")
            dataSet.colors = [UIColor.lightGray]
        } else {
            dataSet = PieChartDataSet(entries: entries, label: "Languages")
            dataSet.colors = ChartColorTemplates.material()
        }

        let data = PieChartData(dataSet: dataSet)
        pieChartView.data = data
        pieChartView.notifyDataSetChanged()
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
