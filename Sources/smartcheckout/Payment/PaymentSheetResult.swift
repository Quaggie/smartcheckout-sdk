import Foundation

public enum PaymentSheetResult {
    case success
    case canceled
    case failed(Error)
}
