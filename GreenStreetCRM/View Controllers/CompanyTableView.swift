//
//  CompanyTableView.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 11/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa

class CompanyTableView: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    //Define the company table outlet
        @IBOutlet weak var companyTable: NSTableView!
    //Define the search field outlet
    @IBOutlet weak var schCompanyTV: NSSearchField!
    
    //Create an instance of the datasource class
    let CDM = CompDataModel.compSharedInstance
    
    //Define an array that will have index 0 = mode (1=add, 2=change) and index 1 = the idCompany of the record to be changed (or 0 if in add mode)
    var repObj = [Int]()
    
       //Define an array controller for comp.array
    var compArrayController:NSArrayController = NSArrayController()
    
    
    //Call the func no of rows in data source that is required by the NSTableViewDataSource protocol
    func numberOfRows(in tableView: NSTableView) -> Int {
        return CDM.compArray.count
    }
    
    //Define the function that will get the data for each cell for each row.
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        //Define constant dict as an NSDictionary and set to the DM instance of the DataModel class at the row being loaded into the table. DM needs to be cast as an NSDictionary. row is passed in as a parameter by the OS
        let tdict:NSDictionary = CDM.compArray[row] as! NSDictionary
        
        //Define strKey as the column identifier for the column being loaded. Column being loaded is passed in as a parameter by the OS
        let strKey = (tableColumn?.identifier)!
        
        //method will return the value from dict (which is loaded from CDM.compArray) for the key that is equal to the column identifier which was loaded to strKey
        return tdict.value(forKey: strKey.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        companyTable.dataSource = self
        companyTable.delegate = self
    }
    
       
    //Prepare for segue to add or edit company
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        //Define constant strSegue which is equal to the segue identifier
        if let strSegue = segue.identifier {
            
            //Test strSegue and if it is the addCompany button
            switch strSegue.rawValue {
            
            //If adding a company
            case "addCompany":
                //Set repObj to add mode and no idCompany
                repObj = [1, 0]
                
                //Set the destination controller and pass the representedobject as repObj
                let auxView = segue.destinationController as! AddCompanyController
                auxView.delegate = self
                auxView.representedObject = repObj
                
            
            //If changing a company
            case "chgCompany":
                //Define constant cdict as an NSDictionary and set to the CDM instance of the DataModel class at the row selected in the table. DM needs to be cast as an NSDictionary.
                let cdict:NSDictionary = CDM.compArray[companyTable.selectedRow] as! NSDictionary
                //Define chgID as the value from cdict for key idCompany ie it returns the value of idCompany at the row selected
                let chgID = cdict["idCompany"]
                //Set repObj to edit mode and pass idCompany
                repObj = [2, chgID] as! [Int]
                
                //Set the destination controller and pass the representedobject as repObj
                let auxView = segue.destinationController as! AddCompanyController
                auxView.delegate = self
                auxView.representedObject = repObj
            
            //Else
            default:
                //Do nothing
                break
            }
            
        }
    }
    
    //The add record method that will be called from the popover
        func addRecord(company: CompanyStruct) {
        
        CDM.insert(company: company)
        
            
        //Reload the table to refresh after add
        companyTable.reloadData()
    }
    
    //The get next primary key that will be called by the popover
    
    func getNxtKey() -> Int {
        
        return Int(CDM.getMaxID())
    }
    
    //The get singlecompany function will be called by the popover to populate the fields ready for edit
    func getSingleCompany(ic: Int) -> CompanyStruct {
        
        let comp = CDM.getSingleCompany(ic: ic)
        return comp
        
    }
    
    //The updatecompany function will be called by the popover
    
    func updateCompany(company: CompanyStruct) {
        CDM.updateCompany(company: company)
        companyTable.reloadData()
        
    }
    
    //Define the buttons
    
    //Add company
    @IBAction func btnAddCompany(_ sender: Any) {
    }
    
    //Edit Company
    @IBAction func btnEditCompany(_ sender: Any) {
    }
    
    //Delete Company
    @IBAction func btnDeleteCompany(_ sender: Any) {
        
        
        //Define constant ddict as an NSDictionary and set to the CDM instance of the DataModel class at the row selected in the table. CDM needs to be cast as an NSDictionary.
        let ddict:NSDictionary = CDM.compArray[companyTable.selectedRow] as! NSDictionary
        //Define delID as the value from ddict for key idCompany ie it returns the value of idCompany at the row selected
        let delID = ddict["idCompany"]
        
        //Need to check whether contacts are attached to company
        
        var ind99 = 2
        
        ind99 = CDM.checkContacts(ic: delID as! Int)
        
        if ind99 == 1 {
            
            //Create an alert to warn of contacts that prevent company deletion
            let alert: NSAlert = NSAlert()
            alert.messageText = "Company cannot be deleted as it has Contacts"
            alert.informativeText = "All Contacts need to be deleted before deleting the Company"
            alert.alertStyle = NSAlert.Style.critical
            alert.addButton(withTitle: "OK")
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
            
        } else {
            
            //Call the delete function on CDM passing in delID as parameter. The delete function will delete the record with this idCompany value
            CDM.deleteRecord(delID as! Int)
            //Get the
            let delIndex = companyTable.selectedRow
            //Remove record from compArray
            CDM.compArray.removeObject(at: delIndex)
            //Reload the table to refresh after delete
            companyTable.reloadData()
            
            }
        
    }
    
    //Sorting the data in the table view need to implement the following method
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
        //Both the array and the table view have "sortDescriptors" which describe the columns and how they are sorted. The sorting request happens in the table and you pass that on to the array:
        //Note: This won't work until you define sorting parameters on each column in the table view in interface builder or in code.
        CDM.compArray.sort(using: tableView.sortDescriptors)
        companyTable.reloadData()
    }
}
