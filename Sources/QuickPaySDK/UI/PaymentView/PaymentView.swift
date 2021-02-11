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
        case applepay = "PaymentApplePay"
        case mobilepay = "PaymentMobilePay"
        case paymentcard = "PaymentCreditCard"
        case vipps = "PaymentVipps"
        
        public func defaultTitle() -> String {
            switch self {
            case .applepay:
                return "Apple Pay"
            case .mobilepay:
                return "MobilePay"
            case .paymentcard:
                return "Cards"
            case .vipps:
                return "Vipps"
            }
        }
    }
    
    @IBInspectable var cellBackgroundColorSelected: UIColor = UIColor(red: 220, green: 230, blue: 255)
    @IBInspectable var cellBackgroundColorUnselected: UIColor = UIColor.clear

    @IBInspectable var cellBorderColorSelected: UIColor = UIColor(red: 220, green: 230, blue: 255)
    @IBInspectable var cellBorderColorUnselected: UIColor = UIColor(red: 170, green: 170, blue: 170)

    @IBOutlet weak var contentView: UIView!
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
        Bundle.module.loadNibNamed("PaymentView", owner: self, options: nil)
        contentView.fixInView(self)
        
        // Init all the payment cells
        self.tableView.register(UINib.init(nibName: "PaymentViewCellCreditCard", bundle: Bundle.module), forCellReuseIdentifier: PaymentMethod.paymentcard.rawValue)
        self.tableView.register(UINib.init(nibName: "PaymentViewCellMobilePay", bundle: Bundle.module), forCellReuseIdentifier: PaymentMethod.mobilepay.rawValue)
        self.tableView.register(UINib.init(nibName: "PaymentViewCellApplePay", bundle: Bundle.module), forCellReuseIdentifier: PaymentMethod.applepay.rawValue)
        self.tableView.register(UINib.init(nibName: "PaymentViewCellVipps123", bundle: Bundle.module), forCellReuseIdentifier: PaymentMethod.vipps.rawValue)

        
        tableView.delegate = self
        tableView.dataSource = self
        
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
        availablePaymentMethods = [PaymentView.PaymentMethod.paymentcard]
        
        if QuickPay.isVippsEnabled ?? false && QuickPay.isVippsAvailableOnDevice() {
            availablePaymentMethods?.insert(PaymentMethod.vipps, at: 0);
        }
        
        if QuickPay.isMobilePayEnabled ?? false && QuickPay.isMobilePayAvailableOnDevice() {
            availablePaymentMethods?.insert(PaymentMethod.mobilepay, at: 0)
        }
        
        if QuickPay.isApplePayEnabled ?? false && QuickPay.isApplePayAvailableOnDevice() {
            availablePaymentMethods?.insert(PaymentMethod.applepay, at: 0)
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
                return UITableViewCell(style: .subtitle, reuseIdentifier: nil)
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
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate, let paymentMethod = availablePaymentMethods?[indexPath.row] {
            delegate.didSelectPaymentMethod(self, paymentMethod: paymentMethod)
        }
    }
    
}

extension PaymentView: PaymentViewCellDelegate {

    public func cellBackgroundColor(_ selected: Bool) -> UIColor {
        return selected ? cellBackgroundColorSelected : cellBackgroundColorUnselected
    }
    
    public func cellBorderColor(_ selected: Bool) -> UIColor {
        return selected ? cellBorderColorSelected : cellBorderColorUnselected
    }
    
}

extension PaymentView: InitializeDelegate {

    public func initializationStarted() {
        // NOP
    }
    
    public func initializationCompleted() {
        self.updateAvailablePaymentMethods()
        self.tableView.reloadData()
        self.invalidateIntrinsicContentSize()
    }
    
}
