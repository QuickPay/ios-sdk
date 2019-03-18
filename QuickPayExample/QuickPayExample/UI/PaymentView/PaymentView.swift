//
//  PaymentController.swift
//  QuickPayExample
//
//  Created on 12/03/2019.
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

protocol PaymentViewDelegate {

    func paymentOptions() -> [PaymentView.PaymentMethod]
    func didSelectPaymentMethod(_ paymentView: PaymentView, paymentMethod: PaymentView.PaymentMethod)
    
}

@IBDesignable
class PaymentView: UIView {

    // MARK: - Enums
    
    enum PaymentMethod: String {
        case creditCard = "PaymentCreditCard"
        case mobilePay = "PaymentMobilePay"
        case applePay = "PaymentApplePay"
    }
    
    @IBInspectable var cellBackgroundColorSelected: UIColor = UIColor(red: 220, green: 230, blue: 255)
    @IBInspectable var cellBackgroundColorUnselected: UIColor = UIColor.clear

    @IBInspectable var cellBorderColorSelected: UIColor = UIColor(red: 220, green: 230, blue: 255)
    @IBInspectable var cellBorderColorUnselected: UIColor = UIColor(red: 170, green: 170, blue: 170)

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
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
    }
    
    
    // MARK: API
    
    func getSelectedPaymentOption() -> PaymentView.PaymentMethod? {
        if let indexPath = tableView.indexPathForSelectedRow, let delegate = delegate {
            return delegate.paymentOptions()[indexPath.row]
        }
        else {
            return nil
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 375, height: Int(tableView.rowHeight) * (delegate?.paymentOptions().count ?? 0))
    }
    
}

extension PaymentView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.paymentOptions().count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let paymentOption = delegate?.paymentOptions()[indexPath.row],
              let cell = tableView.dequeueReusableCell(withIdentifier: paymentOption.rawValue) as? PaymentViewCell else {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "BAHH")
                cell.detailTextLabel?.text = "NOOOO"
                return cell
        }

        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.didSelectPaymentMethod(self, paymentMethod: delegate.paymentOptions()[indexPath.row])
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
