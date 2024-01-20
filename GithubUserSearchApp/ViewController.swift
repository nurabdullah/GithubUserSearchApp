import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var publicRepoCount: UILabel!
    @IBOutlet weak var accountOpenDate: UILabel!
    @IBOutlet weak var location: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func userSearchButton(_ sender: Any) {
        guard let userName = userNameField.text, !userName.isEmpty else {
            // Kullanıcı adı boşsa bir şey yapma
            return
        }

        // GitHub API URL
        let apiUrl = "https://api.github.com/users/\(userName)"

        // URLSession ile GitHub API'ye istek gönderme
        if let url = URL(string: apiUrl) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        // Gelen JSON verisini işleme
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            DispatchQueue.main.async {
                                // Avatar resmini yükleme
                                if let avatarUrlString = json["avatar_url"] as? String,
                                   let avatarUrl = URL(string: avatarUrlString),
                                   let data = try? Data(contentsOf: avatarUrl),
                                   let image = UIImage(data: data) {
                                    let scaledImage = self.resizeImage(image: image, targetSize: CGSize(width: 185, height: 350))
                                    self.userImage.image = scaledImage
                                }

                                // Kullanıcı adı
                                if let name = json["name"] as? String {
                                    self.name.text = name
                                }

                                // Genel repo sayısı
                                if let publicRepos = json["public_repos"] as? Int {
                                    self.publicRepoCount.text = " \(publicRepos)"
                                }

                                // Hesap oluşturulma tarihi
                                if let createdAtString = json["created_at"] as? String,
                                   let createdAtDate = self.convertToDate(dateString: createdAtString) {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "MMM dd, yyyy"
                                    let formattedDate = dateFormatter.string(from: createdAtDate)
                                    self.accountOpenDate.text = "\(formattedDate)"
                                }

                                // Konum
                                if let location = json["location"] as? String {
                                    self.location.text = location
                                }
                            }
                        }
                    } catch {
                        print("JSON işleme hatası: \(error.localizedDescription)")
                    }
                }
            }

            task.resume()
        }
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? UIImage()
    }

    func convertToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: dateString)
    }
}
