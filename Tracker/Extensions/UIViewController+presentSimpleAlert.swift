import UIKit

extension UIViewController {
    func presentSimpleAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: actionTitle, style: .cancel)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
