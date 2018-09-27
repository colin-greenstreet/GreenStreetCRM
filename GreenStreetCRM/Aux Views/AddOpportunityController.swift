//
//  AddOpportunityController.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 19/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa

class AddOpportunityController: NSViewController, NSComboBoxDataSource, NSComboBoxDelegate {

    @IBOutlet weak var cmbCompany: NSComboBox!
    
    @IBOutlet weak var cmbContact: NSComboBox!
    
    @IBOutlet weak var txtOpportunity: NSTextField!
    
    @IBOutlet weak var cmbOppStatus: NSComboBox!
    
    //Initialise a variable repObj that will be set by the representedobject and can then be tested to control mode and if edit which idCompany record is to be edited
    var repObj = [Int]()
    
    //Define delegate that is a reference back to calling view controller. It is set when segue fired
    var delegate: AnyObject?
    
    //Define a variable that will eventually be set to next idOpportunity for insert
    var io = 0
    
    //Define variable that will be used to hold the idCompany associated with the company selected from Combobox
    var idcom = 0
    
    //Define variable that will be used to hold the idContact associated with the contact selected from Combobox
    var idcont = 0
    
    //Define an array to hold company for combobox
    var compIndex: Array<String> = []
    
    //Define an array to hold contact for combobox
    var contIndex: Array<String> = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        cmbCompany.usesDataSource = true
        cmbContact.usesDataSource = true
        //Tell combobox that this class view controller will provide delegate
        cmbCompany.dataSource = self
        cmbContact.dataSource = self
        cmbCompany.delegate = self
        cmbContact.delegate = self
        
        //Populate the company array for loading to combobox
        compIndex = (delegate as! ViewController).getCompany()
        
        //Populate the contact array for loading to combobox
        contIndex = (delegate as! ViewController).getContact()
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        
        switch comboBox {
        case cmbCompany:
            return compIndex.count
        
        case cmbContact:
            return contIndex.count
        
        default:
            return 0
            
        }
                    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        
        switch  comboBox {
        case cmbCompany:
            return compIndex[index]
            
        case cmbContact:
            return contIndex[index]
        default:
            return 0
        }
        
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
            
        //Case 1 is add do nothing
        case 1:
            break
            
        //case 2 is edit
        case 2:
            
            //Need to get existing opportunity record for the table row selected
            let opp = (delegate as! ViewController).getSingleOpportunity(io: repObj[1])
            
            cmbCompany.stringValue = opp.company
            cmbContact.stringValue = opp.listName
            txtOpportunity.stringValue = opp.oppDesc
            cmbOppStatus.stringValue = opp.oppStatus
            
            //Get the idCompany from combobox selection passing in the company from the new selection
            idcom = (delegate as! ViewController).getPrimaryKeyComp(company: cmbCompany.stringValue)
            
            //Call the function to reload the contIndex with only contacts for the company selected
            contIndex = (delegate as!ViewController).getContactForCompany(ic: idcom)
            
            cmbContact.reloadData()
            
        //Default is do nothing
        default:
            break
        }
    }
 
    @IBAction func btnAdd(_ sender: Any) {
        
        //Test on repObj index 0 which is the mode
        switch repObj[0] {
            
        //Case 1 is add
        case 1:
            
            //Define ioi is the idOpportunity to be used on the insert by calling the data source get next function via the view controller as delegate
            io = (delegate as! ViewController).getNxtKey()
            
            //Get the idCompany from combobox selection
            idcom = (delegate as! ViewController).getPrimaryKeyComp(company: cmbCompany.stringValue)
            
            //Get the idContact from combobox selection
            idcont = (delegate as! ViewController).getPrimaryKeyCont(listName: cmbContact.stringValue)
            
            
            //initialise the opportunity struct to be passed into insert function
            let opp = OpportunityStruct(idOpportunity: io, idContact: idcont, idCompany: idcom, company: cmbCompany.stringValue, listName: cmbContact.stringValue, oppDesc: txtOpportunity.stringValue, oppStatus: cmbOppStatus.stringValue)
            
            (delegate as! ViewController).addOpportunity(opportunity: opp)
            
            
            dismiss(self)
            
            
        //case 2 is edit
        case 2:
            
            //Get the idCompany from combobox selection
            idcom = (delegate as! ViewController).getPrimaryKeyComp(company: cmbCompany.stringValue)
            
            //Get the idContact from combobox selection
            idcont = (delegate as! ViewController).getPrimaryKeyCont(listName: cmbContact.stringValue)
            
            
            
            //initialise the opportunity struct to be passed into insert function
            let opp = OpportunityStruct(idOpportunity: repObj[1], idContact: idcont, idCompany: idcom, company: cmbCompany.stringValue, listName: cmbContact.stringValue, oppDesc: txtOpportunity.stringValue, oppStatus: cmbOppStatus.stringValue)
            
            (delegate as!ViewController).updateOpportunity(opportunity: opp)
            
            dismiss(self)
            
        //Default is do nothing
        default:
            break
        }
        
    }
    
    
    
    @IBAction func btnCancel(_ sender: Any) {
        
        dismiss(self)
    }
    
    
    
    //In order to be able to restrict the contacts available when a company is selected use the comboboSelectionDidChange function
    func comboBoxSelectionDidChange(_ notification: Notification) {
        
        //Define a constant combobox that takes the notification object and casts it as an NSCombobox
        let combobox = notification.object as! NSComboBox
        
        //Can now test on the combobox object because we only want to do something if cmbCompany selection changes
        if combobox == cmbCompany {
            
            //The issue with comboboSelectionDidChange function is that the method is fired before the .stringValue is updated. So using .stringValue wont work as it will use the .stringValue from previous selected item. Therefore use index of selected item as this is updated before the comboboSelectionDidChange function is fired
            
            //Define index which is the index of the newly selected item
            let index = cmbCompany.indexOfSelectedItem
            
            //Because the compIndex index will be the same as the index of the selected item we can get the newly selected company from the compIndex
            let company = compIndex[index]
            
            //Get the idCompany from combobox selection passing in the company from the new selection
            idcom = (delegate as! ViewController).getPrimaryKeyComp(company: company)
            
            //Call the function to reload the contIndex with only contacts for the company selected
            contIndex = (delegate as!ViewController).getContactForCompany(ic: idcom)
            
            cmbContact.reloadData()
            
        }
    }
    
    //End of class
}
