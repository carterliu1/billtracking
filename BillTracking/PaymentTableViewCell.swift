//
//  PaymentTableViewCell.swift
//  BillTracking
//
//  Created by Carter Liu on 11/1/20.
//  Copyright © 2020 Carter Liu. All rights reserved.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {

    @IBOutlet weak var amountField: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var recurrenceField: UILabel!
    @IBOutlet weak var typeField: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
