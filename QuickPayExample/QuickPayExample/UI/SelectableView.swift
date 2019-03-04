//
//  SelectableView.swift
//  QuickPayExample
//
//  Created on 01/03/2019.
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

protocol SelectionDelegate {
    func selectionChanged(selectableView: SelectableView)
}

class SelectableView: UIBorderView {
    
    // MARK: - Properties
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                backgroundColor = UIColor(red: 130.0/255.0, green: 255.0/255.0, blue: 130.0/255.0, alpha: 1.0)
            }
            else {
                backgroundColor = UIColor.clear
            }
            
            selectionDelegate?.selectionChanged(selectableView: self)
        }
    }
    
    var selectionDelegate: SelectionDelegate?
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGestureRec)
    }
    
    @objc func viewTapped() {
        isSelected = !isSelected
    }
    
}
