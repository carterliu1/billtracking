//
//  PaymentModel.swift
//  BillTracking
//
//  Created by Carter Liu on 11/1/20.
//  Copyright © 2020 Carter Liu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift

class payments{
    var payments:[payment] = []
    var db = Firestore.firestore()
    
    init() {
        
    }
    
    func getCount() -> Int{
        return payments.count
    }
    
    func getPaymentObjects(item:Int) -> payment{
        return payments[item]
    }

    func removePaymentObject(item:Int)
    {
        let p = getPaymentObjects(item: item)
        db.collection("payments").document(p.type).delete(){ err in
            if let err = err{
                print("Error removing document: \(err)")
            }else{
                print("Document removed")
            }
        }
        
        payments.remove(at: item)
    }
    
    func addPayment(type:String, amount:Double, image:Data, date:String, id:Int){
        let p = payment(type: type, amount: amount, image: image, date: date, id: id)
        payments.append(p)
    }
    
    func addToFirebase(p: payment){
        let pay = payment(type: p.type, amount: p.amount, image: p.image, date: p.date, id: p.id)
        do{
            try db.collection("payments").document(p.type).setData(from: pay)
        }catch let error{
            print("error writing payment \(error)")
        }
    }
    
    func retrievePayments(){
        db.collection("payments").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let result = Result{
                        try document.data(as: payment.self)
                    }
                    switch result {
                    case .success(let p):
                        if let p = p{
                            print(p)
                            self.payments.append(p)
                        }
                        else{
                            print("document does not exist")
                        }
                    case .failure(let error):
                        print("Error decoding payment: \(error)")
                    }
                }
            }
        }
    }
    
}

struct payment: Codable{
    var type:String
    var amount:Double
    var image:Data
    var date:String
    var id:Int
    
    init(type:String, amount:Double, image:Data, date:String, id:Int) {
        self.type = type
        self.amount = amount
        self.image = image
        self.date = date
        self.id = id
    }
}
