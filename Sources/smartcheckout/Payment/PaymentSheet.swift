import UIKit

@MainActor
public final class PaymentSheet {
    private let sessionKey: String
    
    public init(sessionKey: String) {
        self.sessionKey = sessionKey
    }
    
    public func present(from viewController: UIViewController, completion: @escaping (PaymentSheetResult) -> Void) {
        let paymentViewController = PaymentViewController(sessionKey: sessionKey, completion: completion)
        
        if #available(iOS 15.0, *) {
            if let sheet = paymentViewController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.preferredCornerRadius = 20
            }
        }
        
        viewController.present(paymentViewController, animated: true)
    }
}
