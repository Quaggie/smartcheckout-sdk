import UIKit

@MainActor
public final class PaymentSheet {
    private let sessionKey: String
    
    public init(sessionKey: String) {
        self.sessionKey = sessionKey
    }
    
    public func present(from viewController: UIViewController, completion: @escaping (PaymentSheetResult) -> Void) {
        let paymentViewController = PaymentViewController(
            sessionKey: sessionKey,
            onDetentChange: { [self] value in
                viewController.presentedViewController?.sheetPresentationController?.animateChanges { [self] in
                    if #available(iOS 16.0, *) {
                        viewController.presentedViewController?.sheetPresentationController?.detents = [
                            .custom { context in context.maximumDetentValue * CGFloat(value) }
                        ]
                    } else {
                        viewController.presentedViewController?.sheetPresentationController?.detents = [
                            value > 0.5 ? .large() : .medium()
                        ]
                    }
                }
            },
            completion: completion
        )
        
        if #available(iOS 15.0, *) {
            if let sheet = paymentViewController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.preferredCornerRadius = 20
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
        }
        
        viewController.present(paymentViewController, animated: true)
    }
}
