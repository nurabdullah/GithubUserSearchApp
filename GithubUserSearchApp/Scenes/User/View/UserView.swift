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
    
    @IBOutlet weak var userNameTitle: UILabel!
    @IBOutlet weak var publicRepoCountTİtle: UILabel!
    @IBOutlet weak var createdAccountDateTitle: UILabel!
    @IBOutlet weak var locationTitle: UILabel!
    
    @IBOutlet weak var pieChartView: PieChartView!
    private var userViewModel = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        self.updatePieChart(entries: [])
        pieChartView.drawHoleEnabled = false
        hideTitleLabels()
    }
    
    
    func showTitleLabels() {
        userNameTitle.isHidden = false
        publicRepoCountTİtle.isHidden = false
        createdAccountDateTitle.isHidden = false
        locationTitle.isHidden = false
       }

       func hideTitleLabels() {
           userNameTitle.isHidden = true
           publicRepoCountTİtle.isHidden = true
           createdAccountDateTitle.isHidden = true
           locationTitle.isHidden = true
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
                    self?.showTitleLabels()

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
                    self.pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
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
    
    
    private func updatePieChart(entries: [PieChartDataEntry]) {
        var dataSet: PieChartDataSet
        
        if entries.isEmpty {
            dataSet = PieChartDataSet(entries: [PieChartDataEntry(value: 0, label: "")], label: "Veriler Yüklenemedi")
            dataSet.colors = ChartColorTemplates.pastel()
        } else {
            dataSet = PieChartDataSet(entries: entries, label: "Diller")
            dataSet.colors = ChartColorTemplates.pastel()
        }
        
        let entryLabelFont = UIFont.systemFont(ofSize: 17)
        let labelFont = UIFont.boldSystemFont(ofSize: 17)
        dataSet.valueFont = labelFont
        
        
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
