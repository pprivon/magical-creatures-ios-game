import Foundation
import StoreKit

/// StoreManager is a singleton class that handles in-app purchases
class StoreManager: NSObject {
    // MARK: - Singleton
    static let shared = StoreManager()
    
    // MARK: - Properties
    
    // Available in-app purchase products
    private var products: [SKProduct] = []
    
    // Request in progress flag
    private var isProductRequestInProgress = false
    
    // Callback for product request completion
    private var productsRequestCompletion: (([SKProduct]) -> Void)?
    
    // Callback for purchase completion
    private var purchaseCompletion: ((Bool, String?) -> Void)?
    
    // Product identifiers - these will need to be registered in App Store Connect
    enum ProductIdentifier: String, CaseIterable {
        // Cosmetic Packs
        case centaurAppearance1 = "com.magicalcreatures.cosmetic.centaur.forest"
        case centaurAppearance2 = "com.magicalcreatures.cosmetic.centaur.royal"
        case centaurAppearance3 = "com.magicalcreatures.cosmetic.centaur.warrior"
        case visualEffects = "com.magicalcreatures.cosmetic.effects"
        
        // Companion Packs
        case companionWolf = "com.magicalcreatures.companion.wolf"
        case companionOwl = "com.magicalcreatures.companion.owl"
        case companionFox = "com.magicalcreatures.companion.fox"
        
        // Hero Boosts
        case healthBoost = "com.magicalcreatures.boost.health"
        case strengthBoost = "com.magicalcreatures.boost.strength"
        case magicBoost = "com.magicalcreatures.boost.magic"
        case speedBoost = "com.magicalcreatures.boost.speed"
        
        // Remove Ads
        case removeAds = "com.magicalcreatures.noadvertising"
        
        // Bundle Packs
        case allCosmetics = "com.magicalcreatures.bundle.allcosmetics"
        case allCompanions = "com.magicalcreatures.bundle.allcompanions"
    }
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        
        // Setup transaction observer
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    // MARK: - Product Management
    
    /// Fetch available products from App Store
    /// - Parameter completion: Callback with the list of available products
    func fetchProducts(completion: @escaping ([SKProduct]) -> Void) {
        // Return cached products if available
        if !products.isEmpty {
            completion(products)
            return
        }
        
        // Don't start another request if one is in progress
        guard !isProductRequestInProgress else {
            productsRequestCompletion = completion
            return
        }
        
        isProductRequestInProgress = true
        productsRequestCompletion = completion
        
        // Prepare product identifiers
        let productIdentifiers = Set(ProductIdentifier.allCases.map { $0.rawValue })
        
        // Create and start the request
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    /// Get product by identifier
    /// - Parameter identifier: The product identifier
    /// - Returns: The corresponding SKProduct if available
    func product(for identifier: ProductIdentifier) -> SKProduct? {
        return products.first { $0.productIdentifier == identifier.rawValue }
    }
    
    // MARK: - Purchase Processing
    
    /// Initiate a purchase of the specified product
    /// - Parameters:
    ///   - productIdentifier: The product to purchase
    ///   - completion: Callback with result of the purchase (success/failure)
    func purchase(product: ProductIdentifier, completion: @escaping (Bool, String?) -> Void) {
        // Check if payments are allowed
        guard SKPaymentQueue.canMakePayments() else {
            completion(false, "In-app purchases are not allowed on this device.")
            return
        }
        
        // Find the product
        guard let product = self.product(for: product) else {
            // If we don't have the product yet, fetch them first
            fetchProducts { [weak self] _ in
                // Retry purchase once we have the products
                if let product = self?.product(for: product) {
                    self?.startPurchase(product: product, completion: completion)
                } else {
                    completion(false, "Product not available for purchase.")
                }
            }
            return
        }
        
        // Start the purchase process with the found product
        startPurchase(product: product, completion: completion)
    }
    
    /// Start the actual purchase process
    /// - Parameters:
    ///   - product: The product to purchase
    ///   - completion: Callback with result
    private func startPurchase(product: SKProduct, completion: @escaping (Bool, String?) -> Void) {
        purchaseCompletion = completion
        
        // Create and add the payment to the queue
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    /// Process the purchase based on the product type
    /// - Parameter productIdentifier: The purchased product identifier
    func processPurchase(productIdentifier: String) {
        // Check which type of product was purchased
        if productIdentifier.contains("cosmetic") {
            GameManager.shared.processCosmeticPurchase(productIdentifier)
        } else if productIdentifier.contains("companion") {
            GameManager.shared.processHelperAnimalPurchase(productIdentifier)
        } else if productIdentifier.contains("boost") {
            GameManager.shared.processPowerBoostPurchase(productIdentifier)
        } else if productIdentifier == ProductIdentifier.removeAds.rawValue {
            GameManager.shared.recordPurchase("AdFreeExperience")
        } else if productIdentifier.contains("bundle") {
            // Process bundle purchases
            if productIdentifier == ProductIdentifier.allCosmetics.rawValue {
                // Record all cosmetic products as purchased
                GameManager.shared.recordPurchase(ProductIdentifier.centaurAppearance1.rawValue)
                GameManager.shared.recordPurchase(ProductIdentifier.centaurAppearance2.rawValue)
                GameManager.shared.recordPurchase(ProductIdentifier.centaurAppearance3.rawValue)
                GameManager.shared.recordPurchase(ProductIdentifier.visualEffects.rawValue)
            } else if productIdentifier == ProductIdentifier.allCompanions.rawValue {
                // Record all companion products as purchased
                GameManager.shared.recordPurchase(ProductIdentifier.companionWolf.rawValue)
                GameManager.shared.recordPurchase(ProductIdentifier.companionOwl.rawValue)
                GameManager.shared.recordPurchase(ProductIdentifier.companionFox.rawValue)
            }
        }
        
        // Save the game state after processing the purchase
        GameManager.shared.saveGameState()
    }
    
    /// Restore previously purchased products
    /// - Parameter completion: Callback with result of the restore process
    func restorePurchases(completion: @escaping (Bool, String?) -> Void) {
        purchaseCompletion = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    /// Get formatted price for a product
    /// - Parameter product: The product
    /// - Returns: A formatted price string
    func formattedPrice(for product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? "\(product.price)"
    }
    
    // MARK: - Cleanup
    
    /// Cleanup resources when app terminates
    func cleanup() {
        SKPaymentQueue.default().remove(self)
    }
}

// MARK: - SKProductsRequestDelegate
extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // Store the received products
        products = response.products
        
        // Log any invalid product identifiers
        if !response.invalidProductIdentifiers.isEmpty {
            print("Invalid product identifiers: \(response.invalidProductIdentifiers)")
        }
        
        // Notify completion
        DispatchQueue.main.async { [weak self] in
            self?.isProductRequestInProgress = false
            self?.productsRequestCompletion?(response.products)
            self?.productsRequestCompletion = nil
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Product request failed: \(error.localizedDescription)")
        
        DispatchQueue.main.async { [weak self] in
            self?.isProductRequestInProgress = false
            self?.productsRequestCompletion?([])
            self?.productsRequestCompletion = nil
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // Payment was successful
                completeTransaction(transaction)
            case .failed:
                // Payment failed
                failedTransaction(transaction)
            case .restored:
                // Previous purchase was restored
                restoreTransaction(transaction)
            case .deferred, .purchasing:
                // Transaction is in progress, do nothing yet
                break
            @unknown default:
                break
            }
        }
    }
    
    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        // Process the purchase
        processPurchase(productIdentifier: transaction.payment.productIdentifier)
        
        // Notify completion handler
        DispatchQueue.main.async { [weak self] in
            self?.purchaseCompletion?(true, nil)
            self?.purchaseCompletion = nil
        }
        
        // Finish the transaction
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func failedTransaction(_ transaction: SKPaymentTransaction) {
        var errorMessage = "Purchase failed."
        if let error = transaction.error {
            errorMessage = error.localizedDescription
        }
        
        // Notify completion handler
        DispatchQueue.main.async { [weak self] in
            self?.purchaseCompletion?(false, errorMessage)
            self?.purchaseCompletion = nil
        }
        
        // Finish the transaction
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else {
            return
        }
        
        // Process the restored purchase
        processPurchase(productIdentifier: productIdentifier)
        
        // Finish the transaction
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        // Notify completion handler of successful restore
        DispatchQueue.main.async { [weak self] in
            self?.purchaseCompletion?(true, nil)
            self?.purchaseCompletion = nil
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        // Notify completion handler of restore failure
        DispatchQueue.main.async { [weak self] in
            self?.purchaseCompletion?(false, error.localizedDescription)
            self?.purchaseCompletion = nil
        }
    }
}
