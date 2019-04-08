//
//  PaymentController.swift
//  QuickPayExample
//
//  Created on 12/03/2019.
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation
import PassKit

public protocol PaymentViewDelegate {

    /// This function is called whenever a payment method is selected
    func didSelectPaymentMethod(_ paymentView: PaymentView, paymentMethod: PaymentView.PaymentMethod)
    
    /// Return the string used by the cell representing a payment method
    /// You can access the default english title with ´paymentMethod.defaultTitle()´
    func titleForPaymentMethod(_ paymentView: PaymentView, paymentMethod: PaymentView.PaymentMethod) -> String
    
}

public class PaymentView: UIView {

    // MARK: - Enums
    
    public enum PaymentMethod: String {
        case applePay = "PaymentApplePay"
        case mobilePay = "PaymentMobilePay"
        case creditCard = "PaymentCreditCard"
        
        public func defaultTitle() -> String {
            switch self {
            case .applePay:
                return "Apple Pay"
            case .mobilePay:
                return "MobilePay"
            case .creditCard:
                return "Cards"
            }
        }
    }
    
    @IBInspectable var cellBackgroundColorSelected: UIColor = UIColor(red: 220, green: 230, blue: 255)
    @IBInspectable var cellBackgroundColorUnselected: UIColor = UIColor.clear

    @IBInspectable var cellBorderColorSelected: UIColor = UIColor(red: 220, green: 230, blue: 255)
    @IBInspectable var cellBorderColorUnselected: UIColor = UIColor(red: 170, green: 170, blue: 170)

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var availablePaymentMethods: [PaymentMethod]?
    public var delegate: PaymentViewDelegate?
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        if let bundle = Bundle(identifier: QuickPay.sdkBundleIdentifier) {
            bundle.loadNibNamed("PaymentView", owner: self, options: nil)
            contentView.fixInView(self)

            // Init all the payment cells
            self.tableView.register(UINib.init(nibName: "PaymentViewCellCreditCard", bundle: bundle), forCellReuseIdentifier: PaymentMethod.creditCard.rawValue)
            self.tableView.register(UINib.init(nibName: "PaymentViewCellMobilePay", bundle: bundle), forCellReuseIdentifier: PaymentMethod.mobilePay.rawValue)
            self.tableView.register(UINib.init(nibName: "PaymentViewCellApplePay", bundle: bundle), forCellReuseIdentifier: PaymentMethod.applePay.rawValue)
        }
        else {
            QuickPay.logDelegate?.log("Could not load the needed Nib files from bundle")
        }
        
        updateAvailablePaymentMethods()
    }
    
    
    // MARK: API
    
    public func getSelectedPaymentOption() -> PaymentView.PaymentMethod? {
        if let indexPath = tableView.indexPathForSelectedRow, let paymentMethod = availablePaymentMethods?[indexPath.row] {
            return paymentMethod
        }
        else {
            return nil
        }
    }

    private func updateAvailablePaymentMethods() {
        availablePaymentMethods = [PaymentView.PaymentMethod.creditCard]
        
        if QuickPay.isMobilePayOnlineEnabled ?? false && QuickPay.isMobilePayAvailableOnDevice() {
            availablePaymentMethods?.insert(PaymentMethod.mobilePay, at: 0)
        }
        
        if QuickPay.isApplePayEnabled ?? false && QuickPay.isApplePayAvailableOnDevice() {
            availablePaymentMethods?.insert(PaymentMethod.applePay, at: 0)
        }
    }

    
    // MARK: - Lifecycle
    
    override public var intrinsicContentSize: CGSize {
        if let paymentMethods = availablePaymentMethods {
            return CGSize(width: 375, height: Int(tableView.rowHeight) * paymentMethods.count)
        }
        else {
            // This should not happen
            return CGSize(width: 375, height: Int(100))
        }
    }
    
}

extension PaymentView: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availablePaymentMethods?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let paymentMethod = availablePaymentMethods?[indexPath.row],
            let cell = tableView.dequeueReusableCell(withIdentifier: paymentMethod.rawValue) as? PaymentViewCell else {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "BAHH")
                cell.detailTextLabel?.text = "NOOOO"
                return cell
        }
        
        if let delegateTitle = delegate?.titleForPaymentMethod(self, paymentMethod: paymentMethod) {
            cell.titleLabel?.text = delegateTitle
        }
        else {
            cell.titleLabel?.text = paymentMethod.defaultTitle()
        }

        cell.delegate = self
        return cell
    }
    
    private func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    private func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate, let paymentMethod = availablePaymentMethods?[indexPath.row] {
            delegate.didSelectPaymentMethod(self, paymentMethod: paymentMethod)
        }
    }
    
}

extension PaymentView: PaymentViewCellDelegate {

    func cellBackgroundColor(_ selected: Bool) -> UIColor {
        return selected ? cellBackgroundColorSelected : cellBackgroundColorUnselected
    }
    
    func cellBorderColor(_ selected: Bool) -> UIColor {
        return selected ? cellBorderColorSelected : cellBorderColorUnselected
    }
    
}

extension PaymentView: InitializeDelegate {

    public func initializaationStarted() {
        // NOP
    }
    
    public func initializaationCompleted() {
        self.updateAvailablePaymentMethods()
        self.tableView.reloadData()
        self.invalidateIntrinsicContentSize()
    }
    
}
