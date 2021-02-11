//
//  PaymentViewCell.swift
//  QuickPayExample
//
//  Created on 15/03/2019.
//  Copyright © 2019 QuickPay. All rights reserved.
//

import UIKit

public protocol PaymentViewCellDelegate {

    func cellBackgroundColor(_ selected: Bool) -> UIColor
    func cellBorderColor(_ selected: Bool) -> UIColor
    
}

public class PaymentViewCell: UITableViewCell {
    
    // MARK: - Properties and Outlets
    
    @IBOutlet weak var borderView: UIBorderView!
    @IBOutlet weak var titleLabel: UILabel!
    var delegate: PaymentViewCellDelegate?
    

    // MARK: - Init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    
    // MARK: - Lifecycle
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        borderView.backgroundColor = delegate?.cellBackgroundColor(selected)
        borderView.borderColor = delegate?.cellBorderColor(selected)
    }
    
}
