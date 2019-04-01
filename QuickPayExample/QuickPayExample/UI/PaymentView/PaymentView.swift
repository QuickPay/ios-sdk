//
//  PaymentController.swift
//  QuickPayExample
//
//  Created on 12/03/2019.
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation
import PassKit
import QuickPaySDK

protocol PaymentViewDelegate {

    /// This function is called whenever a payment method is selected
    func didSelectPaymentMethod(_ paymentView: PaymentView, paymentMethod: PaymentView.PaymentMethod)
    
    /// Return the string used by the cell representing a payment method
    /// Return nil to fallback to default titles
    func titleForPaymentMethod(_ paymentView: PaymentView, paymentMethod: PaymentView.PaymentMethod) -> String?
    
}

class PaymentView: UIView {

    // MARK: - Enums
    
    enum PaymentMethod: String {
        case applePay = "PaymentApplePay"
        case mobilePay = "PaymentMobilePay"
        case creditCard = "PaymentCreditCard"
        
        func defaultTitle() -> String {
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
    var delegate: PaymentViewDelegate?
    
    
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
        Bundle.main.loadNibNamed("PaymentView", owner: self, options: nil)
        contentView.fixInView(self)
        
        // Init all the payment cells
        self.tableView.register(UINib.init(nibName: "PaymentViewCellCreditCard", bundle: nil), forCellReuseIdentifier: PaymentMethod.creditCard.rawValue)
        self.tableView.register(UINib.init(nibName: "PaymentViewCellMobilePay", bundle: nil), forCellReuseIdentifier: PaymentMethod.mobilePay.rawValue)
        self.tableView.register(UINib.init(nibName: "PaymentViewCellApplePay", bundle: nil), forCellReuseIdentifier: PaymentMethod.applePay.rawValue)
        
        // TODO: Figure out what cababilities the user has
        availablePaymentMethods = [PaymentView.PaymentMethod.creditCard]
        
        if QuickPay.isMobilePayAvailable() {
            availablePaymentMethods?.insert(PaymentMethod.mobilePay, at: 0)
        }
        
        
        if PKPaymentAuthorizationController.canMakePayments() {
            availablePaymentMethods?.insert(PaymentMethod.applePay, at: 0)
        }
    }
    
    // MARK: - Helper functions
    
    
    
    
    // MARK: API
    
    func getSelectedPaymentOption() -> PaymentView.PaymentMethod? {
        if let indexPath = tableView.indexPathForSelectedRow, let paymentMethod = availablePaymentMethods?[indexPath.row] {
            return paymentMethod
        }
        else {
            return nil
        }
    }
    
    override var intrinsicContentSize: CGSize {
        if let paymentMethods = availablePaymentMethods {
            return CGSize(width: 375, height: Int(tableView.rowHeight) * paymentMethods.count)
        }
        else {
            // TODO: Show a loading spinner?
            return CGSize(width: 375, height: Int(100))
        }
    }
    
}

extension PaymentView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availablePaymentMethods?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
