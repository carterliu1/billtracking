//
//  ViewController.swift
//  BillTracking
//
//  Created by Carter Liu on 11/1/20.
//  Copyright © 2020 Carter Liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var datePicker:UIDatePicker = UIDatePicker()
    let imagePicker = UIImagePickerController()
    var imageSelected: UIImage?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentList.getCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTable.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! PaymentTableViewCell
        cell.layer.borderWidth = 1.0
        let payment = paymentList.getPaymentObjects(item: indexPath.row)
        cell.typeField.text = payment.type
        cell.amountField.text = "$" + String(payment.amount)
        cell.dateField.text = payment.date
        cell.recurrenceField.text = ""
        cell.typeField.sizeToFit()
        cell.amountField.sizeToFit()
        return cell
    }
    

    override func viewDidLoad() {
        let workItem = DispatchWorkItem{
            self.myTable.reloadData()
        }
        paymentList.retrievePayments()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: workItem)
        super.viewDidLoad()
        myTable.delegate = self
        myTable.dataSource = self
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
        
    }

    override func viewDidAppear(_ animated: Bool) {
        myTable.reloadData()
    }
    
    var paymentList:payments = payments()
    
    @IBOutlet weak var myTable: UITableView!
    
    @IBAction func addPayment(_ sender: Any) {
        let alert = UIAlertController(title: "Upload Receipt", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { action in
            self.pickImage(choice: 0)
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {action in
            self.pickImage(choice: 1)
        }))
        self.present(alert, animated: true)
    }
    
    func pickImage(choice:Int){
        if(choice == 0){
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.imagePicker.modalPresentationStyle = .popover
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        else if(choice == 1){
            if(UIImagePickerController.isSourceTypeAvailable(.camera)){
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.imagePicker.cameraCaptureMode = .photo
                self.imagePicker.modalPresentationStyle = .fullScreen
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            
        }
        else{
            print("No Camera")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let img = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imagePicked(image: img.jpegData(compressionQuality: 0.25)!)
    }
    
    func imagePicked(image:Data){

        let alert = UIAlertController(title: "Add Payment", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Payment Type"
        })
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Amount"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let type = alert.textFields?.first?.text, let amount = alert.textFields?[1].text{
                let result = amount.filter("0123456789.".contains)
                self.pickDate(image: image, type: type, amount: result)
            }
        }))
        self.present(alert, animated: true)
    }
    
    func pickDate(image: Data, type: String, amount:String){
        datePicker.frame = CGRect(x: 0, y: 15, width: 270, height: 200)
        datePicker.datePickerMode = .date
        let alert = UIAlertController(title: "Payment Date\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
        alert.view.addSubview(datePicker)
        let selectAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.paymentList.addPayment(type: type, amount: Double(amount)!, image: image, date: self.getSelectedDate(), id: self.paymentList.getCount())
            let pay = payment(type: type, amount: Double(amount)!, image: image, date: self.getSelectedDate(), id: self.paymentList.getCount())
            self.paymentList.addToFirebase(p: pay)
            let indexPath = IndexPath (row: self.paymentList.getCount() - 1, section: 0)
            self.myTable.beginUpdates()
            self.myTable.insertRows(at: [indexPath], with: .automatic)
            self.myTable.endUpdates()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(selectAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func getSelectedDate() -> String{
        let format = DateFormatter()
        format.dateStyle = .short
        return format.string(from: self.datePicker.date)
    }
    
    @IBAction func findATM(_ sender: Any) {
    }
    
    // delete table entry
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    private func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell.EditingStyle { return UITableViewCell.EditingStyle.delete }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
      
        paymentList.removePaymentObject(item: indexPath.row)
        
        self.myTable.beginUpdates()
        self.myTable.deleteRows(at: [indexPath], with: .automatic)
        self.myTable.endUpdates()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if(segue.identifier == "detailView"){
            let selectedIndex: IndexPath = self.myTable.indexPath(for: sender as! UITableViewCell)!
            let item = paymentList.getPaymentObjects(item: selectedIndex.row)
            if let viewController: DetailViewController = segue.destination as? DetailViewController{
                viewController.item = item
            }
        }
    }
}

