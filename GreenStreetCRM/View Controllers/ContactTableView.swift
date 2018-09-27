//
//  ContactTableView.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 15/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa

class ContactTableView: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    
    @IBOutlet weak var contactTable: NSTableView!
    
    //Create an instance of the contact datasource class
    let CDM = ContDataModel.contSharedInstance
    
    //Create an instance of the company datasource class
    let CODM = CompDataModel.compSharedInstance
    
    //Define an array that will have index 0 = mode (1=add, 2=change) and index 1 = the idCompany of the record to be changed (or 0 if in add mode)
    var repObj = [Int]()
    var company = ""
    
    //Call the func no of rows in data source that is required by the NSTableViewDataSource protocol
    func numberOfRows(in tableView: NSTableView) -> Int {
        return CDM.contArray.count
    }
    
    //Define the function that will get the data for each cell for each row.
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        //Define constant dict as an NSDictionary and set to the DM instance of the DataModel class at the row being loaded into the table. DM needs to be cast as an NSDictionary. row is passed in as a parameter by the OS
        let tdict:NSDictionary = CDM.contArray[row] as! NSDictionary
        
        //Define strKey as the column identifier for the column being loaded. Column being loaded is passed in as a parameter by the OS
        let strKey = (tableColumn?.identifier)!
        
        //method will return the value from dict (which is loaded from CDM.compArray) for the key that is equal to the column identifier which was loaded to strKey
        return tdict.value(forKey: strKey.rawValue)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
        contactTable.dataSource = self
        contactTable.delegate = self
    }
    
    //Prepare for segue to add or edit company
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        //Define constant strSegue which is equal to the segue identifier
        if let strSegue = segue.identifier {
            
            //Test strSegue and if it is the addCompany button
            switch strSegue.rawValue {
                
            //If adding a contact
            case "addContact":
                //Set repObj to add mode and no idContact
                repObj = [1, 0]
                
                //Set the destination controller and pass the representedobject as repObj
                let auxView = segue.destinationController as! AddContactController
                auxView.delegate = self
                auxView.representedObject = repObj
                
                
            //If changing a company
            case "chgContact":
                //Define constant cdict as an NSDictionary and set to the CDM instance of the DataModel class at the row selected in the table. DM needs to be cast as an NSDictionary.
                let cdict:NSDictionary = CDM.contArray[contactTable.selectedRow] as! NSDictionary
                //Define chgID as the value from cdict for key idCompany ie it returns the value of idCompany at the row selected
                let chgID = cdict["idContact"]
                //Set repObj to edit mode and pass idCompany
                repObj = [2, chgID] as! [Int]
                
                //Set the destination controller and pass the representedobject as repObj
                let auxView = segue.destinationController as! AddContactController
                auxView.delegate = self
                auxView.representedObject = repObj
                
            //Else
            default:
                //Do nothing
                break
            }
            
        }
    }
    
    
    @IBAction func btnAddContact(_ sender: Any) {
    }
    
    @IBAction func btnEditContact(_ sender: Any) {
    }
    
    @IBAction func btnDeleteContact(_ sender: Any) {
        
        //Define constant ddict as an NSDictionary and set to the CDM instance of the DataModel class at the row selected in the table. CDM needs to be cast as an NSDictionary.
        let ddict:NSDictionary = CDM.contArray[contactTable.selectedRow] as! NSDictionary
        //Define delID as the value from ddict for key idCompany ie it returns the value of idCompany at the row selected
        let delID = ddict["idContact"]
        
        //Need to check whether opportunities are attached to contact
        
        var ind99 = 2
        
        ind99 = CDM.checkOpportunities(ic: delID as! Int)
        
        if ind99 == 1 {
            
            //Create an alert to warn of opportunities that prevent contact deletion
            let alert: NSAlert = NSAlert()
            alert.messageText = "Contact cannot be deleted as it has Opportunities"
            alert.informativeText = "All Opportunities need to be deleted before deleting the Contact"
            alert.alertStyle = NSAlert.Style.critical
            alert.addButton(withTitle: "OK")
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
            
        } else {
        
        
        //Call the delete function on CDM passing in delID as parameter. The delete function will delete the record with this idCotact value
        CDM.deleteRecord(delID as! Int)
        //Get the
        let delIndex = contactTable.selectedRow
        //Remove record from compArray
        CDM.contArray.removeObject(at: delIndex)
        //Reload the table to refresh after delete
        contactTable.reloadData()
        }
    }
    
    //Sorting the data in the table view need to implement the following method
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
        //Both the array and the table view have "sortDescriptors" which describe the columns and how they are sorted. The sorting request happens in the table and you pass that on to the array:
        //Note: This won't work until you define sorting parameters on each column in the table view in interface builder or in code.
        CDM.contArray.sort(using: tableView.sortDescriptors)
        contactTable.reloadData()
    }
    
    //The get singlecompany function will be called by the popover to populate the fields ready for edit
    func getSingleContact(ic: Int) -> ContactStruct {
        
        let cont = CDM.getSingleContact(ic: ic)
        return cont
        
    }
    
    //The get company function will be called by the popover to populate the company combobox
    func getCompany() -> Array<String> {
        
        let compIndex = CODM.compIndex
        return compIndex
        
    }
    
    //The getPrimaryKey will be called by the popover to populate idCompany
    
    func getPrimaryKey(company: String) -> Int {
        
        let idc = CODM.getPrimaryKey(company: company)
        
        return idc
    }
    
    func addContact(contact: ContactStruct) {
        CDM.insert(contact: contact)
        
        //Reload the table to refresh after add
        contactTable.reloadData()
    }
    
    //The get next primary key that will be called by the popover
    
    func getNxtKey() -> Int {
        
        return Int(CDM.getMaxID())
    }
    
    //The update contact function will be called by the popover
    
    func updateContact(contact: ContactStruct) {
        CDM.updateContact(contact: contact)
        contactTable.reloadData()
        
    }
    
    //class end bracket
}
