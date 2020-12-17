//
//  DetailViewController.swift
//  BillTracking
//
//  Created by Carter Liu on 11/1/20.
//  Copyright © 2020 Carter Liu. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var item: payment?
    
    @IBOutlet weak var typeText: UILabel!
    @IBOutlet weak var amountText: UILabel!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeText.text = "Payment: \(item?.type ?? "")"
        amountText.text = "Price: $\(String(item!.amount))"
        dateText.text = "Date: \(item?.date ?? "")"
        imageView.image = UIImage(data: item!.image)
        typeText.sizeToFit()
        amountText.sizeToFit()
        dateText.sizeToFit()
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
