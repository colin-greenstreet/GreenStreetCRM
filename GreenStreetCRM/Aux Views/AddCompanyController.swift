//
//  AddCompanyController.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 03/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa

class AddCompanyController: NSViewController {

    //Company name input field
    @IBOutlet weak var txtCompany: NSTextField!
    //Company type combobox
    @IBOutlet weak var cmbCompType: NSComboBox!
    
    //Initialise a variable repObj that will be set by the representedobject and can then be tested to control mode and if edit which idCompany record is to be edited
    var repObj = [Int]()
    
    //Define delegate that is a reference back to calling view controller. It is set when segue fired
    var delegate: AnyObject?
    
    var ic = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    
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
            let comp = (delegate as! CompanyTableView).getSingleCompany(ic: repObj[1])
            
            txtCompany.stringValue = comp.company
            cmbCompType.stringValue = comp.compType
            
            
        //Default is do nothing
        default:
            break
        }
    }
    
    //Button to add new contact or save edit
    @IBAction func btnAddCompany(_ sender: Any) {
        
        //Test on repObj index 0 which is the mode
        switch repObj[0] {
            
        //Case 1 is add
        case 1:
            
        //Define ic is the idCompany to be used on the insert by calling the data source get next function via the view controller as delegate
            ic = (delegate as! CompanyTableView).getNxtKey()
        //initialise the company struct to be passed into insert function
            let cmp = CompanyStruct(idCompany: ic, company: txtCompany.stringValue, compType: cmbCompType.stringValue)
        
            (delegate as! CompanyTableView).addRecord(company: cmp)
            
        
            dismiss(self)
            
            
        //case 2 is edit
        case 2:
            
             let cmp = CompanyStruct(idCompany: repObj[1], company: txtCompany.stringValue, compType: cmbCompType.stringValue)
            (delegate as! CompanyTableView).updateCompany(company: cmp)
            
            dismiss(self)
            
        //Default is do nothing
        default:
            break
        }
        
    }
    
    //Button to cancel popover
    @IBAction func btnCancel(_ sender: Any) {
        dismiss(self)
    }
    
    
    
}
