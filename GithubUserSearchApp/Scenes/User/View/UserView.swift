import UIKit
import Charts

class UserView: UIViewController, ChartViewDelegate {

    var pieChart = PieChartView()

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var publicRepoCountLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var createdAccountDateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var deneme: UIView!
    private var userViewModel = UserViewModel()
    
 

    

    override func viewDidLoad() {
        super.viewDidLoad()
        pieChart.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let chartSize = min(self.deneme.frame.size.width, self.deneme.frame.size.height)

        pieChart.frame = CGRect(x: 0, y: 0, width: chartSize, height: chartSize)
        pieChart.center = CGPoint(x: deneme.frame.size.width / 2, y: deneme.frame.size.height / 2)
        pieChart.removeFromSuperview()
        deneme.addSubview(pieChart)
        deneme.bringSubviewToFront(pieChart)
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

        userViewModel.getUserLanguages(username: username) { [weak self] result in
            switch result {
            case .success(let languages):
                DispatchQueue.main.async {
                    self?.showLanguages(languages)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.showAlert(message: "Kullanıcı dilleri alınamadı.")
                }
            }
        }
    }

    private func showLanguages(_ languages: [String: Int]) {
        showTopLanguagesWithPercentage(languages)
    }

    private func showTopLanguagesWithPercentage(_ languages: [String: Int], topCount: Int = 5) {
            let sortedLanguages = languages.sorted { $0.value > $1.value }.prefix(topCount)
            var entries = [ChartDataEntry]()
            var labels = [String]()

            for (index, (language, byteCount)) in sortedLanguages.enumerated() {
                let percentage = Double(byteCount) / Double(languages.values.reduce(0, +)) * 100
                entries.append(ChartDataEntry(x: Double(index), y: percentage))
                labels.append("\(language): \(String(format: "%.2f%%", percentage))")
                print("\(language): \(byteCount)")
            }

            let set = PieChartDataSet(entries: entries, label: "")
            set.colors = ChartColorTemplates.pastel()
            set.sliceSpace = 2.0

            let data = PieChartData(dataSet: set)
            pieChart.data = data

            // Dil isimlerini yüzdelik değerleriyle birleştirip etiket olarak eklemek için
            set.valueColors = labels.map { _ in UIColor.black }
            set.valueTextColor = UIColor.black

            data.setValueFormatter(DefaultValueFormatter(formatter: NumberFormatter()))
            
            // Grafik güncellendikçe, bunu UI üzerinde göstermek için:
            pieChart.notifyDataSetChanged()
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

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
