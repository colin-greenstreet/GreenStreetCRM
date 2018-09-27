//
//  AddContactController.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 15/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa

class AddContactController: NSViewController, NSComboBoxDataSource, NSComboBoxDelegate {

    @IBOutlet weak var cmbCompany: NSComboBox!
    
    @IBOutlet weak var txtFirstName: NSTextField!
    
    @IBOutlet weak var txtLastName: NSTextField!
    
    @IBOutlet weak var txtEmail: NSTextField!
    
    @IBOutlet weak var txtDD: NSTextField!
    
    @IBOutlet weak var txtMobile: NSTextField!
    
    //Initialise a variable repObj that will be set by the representedobject and can then be tested to control mode and if edit which idCompany record is to be edited
    var repObj = [Int]()
    
    //Define delegate that is a reference back to calling view controller. It is set when segue fired
    var delegate: AnyObject?
    
    //Define a variable that will eventually be set to next idContact for insert
    var ic = 0
    
    //Define variable that will be used to hold the idCompany associated with the company selected from Combobox
    var idcom = 0
    
    var compIndex: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        cmbCompany.usesDataSource = true
        //Tell combobox that this class view controller will provide delegate
        cmbCompany.dataSource = self
        cmbCompany.delegate = self
        
        //Populate the array for loading to combobox
        compIndex = (delegate as! ContactTableView).getCompany()
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return compIndex.count
        
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return compIndex[index]
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            
            //set repObj to the representedobject passed from the view controller
            repObj = representedObject as! [Int]
        }
    }
    
    
    
    override func viewWillAppear() {
        
        //Test on repObj index 0 which is the mode
        switch repObj[0] {
            
        //Case 1 is add - do nothing on load
        case 1:
            break
            
        //case 2 is edit
        case 2:
            
            //Need to get existing company record for the table row selected
            let cont = (delegate as! ContactTableView).getSingleContact(ic: repObj[1])
            
            //Load the screen fields
            cmbCompany.stringValue = cont.company
            txtFirstName.stringValue = cont.firstName
            txtLastName.stringValue = cont.lastName
            txtEmail.stringValue = cont.email!
            txtDD.stringValue = cont.DD!
            txtMobile.stringValue = cont.mobile!
            
            
        //Default is do nothing
        default:
            break
        }
    }
    
    @IBAction func btnAddContact(_ sender: Any) {
        
        //Test on repObj index 0 which is the mode
        switch repObj[0] {
            
        //Case 1 is add
        case 1:
            
            //Define ic is the idContact to be used on the insert by calling the data source get next function via the view controller as delegate
            ic = (delegate as! ContactTableView).getNxtKey()
            
            //Define ListName as the concat of firs and last name
            let ln = "\(txtFirstName.stringValue) \(txtLastName.stringValue)"
            
            //Get the idCompany from combobox selection
            idcom = (delegate as! ContactTableView).getPrimaryKey(company: cmbCompany.stringValue)
            
            
            //initialise the contact struct to be passed into insert function
            let con = ContactStruct(idContact: ic, idCompany: idcom, company: "", firstName: txtFirstName.stringValue, lastName: txtLastName.stringValue, listName: ln, email: txtEmail.stringValue, DD: txtDD.stringValue, mobile: txtMobile.stringValue)
            
            (delegate as! ContactTableView).addContact(contact: con)
            
            
            dismiss(self)
            
            
        //case 2 is edit
        case 2:
            
            //Get the idCompany from combobox selection
            idcom = (delegate as! ContactTableView).getPrimaryKey(company: cmbCompany.stringValue)
            
            //Define ListName as the concat of firs and last name
            let ln = "\(txtFirstName.stringValue) \(txtLastName.stringValue)"
            
            let con = ContactStruct(idContact: repObj[1], idCompany: idcom, company: "", firstName: txtFirstName.stringValue, lastName: txtLastName.stringValue, listName: ln, email: txtEmail.stringValue, DD: txtDD.stringValue, mobile: txtMobile.stringValue)
            
            (delegate as!ContactTableView).updateContact(contact: con)
            
            dismiss(self)
            
        //Default is do nothing
        default:
            break
        }
        
    }
    
    
    @IBAction func btnCancel(_ sender: Any) {
        
        dismiss(self)
    }
    
    
}
