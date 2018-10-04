//
//  CompanyTableView.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 11/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa

class CompanyTableView: NSViewController {

    //Define the company table outlet
    @IBOutlet weak var companyTable: NSTableView!
    //Define the array controller
    @IBOutlet var companyAC: NSArrayController!
    
    //Create an instance of the datasource class
    let CDM = CompDataModel.compSharedInstance
    
    //Define an array that will have index 0 = mode (1=add, 2=change) and index 1 = the idCompany of the record to be changed (or 0 if in add mode)
    var repObj = [Int]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        for comp in CDM.compArray {
            
            self.companyAC.addObject(comp)
        }
        
        companyTable.sortDescriptors = [NSSortDescriptor(key: "company", ascending: true, selector: #selector(NSString.compare(_:)))]
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
                let comp:CompanyStruct = CDM.compArray[companyTable.selectedRow]
                //Define chgID as the value from cdict for key idCompany ie it returns the value of idCompany at the row selected
                let chgID = comp.idCompany
                //Set repObj to edit mode and pass idCompany
                repObj = [2, chgID]
                
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
            
            let range : NSRange = NSMakeRange(0, (companyAC.arrangedObjects as AnyObject).count)
            let indexSet : NSIndexSet = NSIndexSet(indexesIn: range)
            
            companyAC.remove(atArrangedObjectIndexes: indexSet as IndexSet)
            
            for comp in CDM.compArray {
                
                self.companyAC.addObject(comp)
            }
            
            companyTable.reloadData()
            
            companyTable.sortDescriptors = [NSSortDescriptor(key: "company", ascending: true, selector: #selector(NSString.compare(_:)))]
            
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
        
        let range : NSRange = NSMakeRange(0, (companyAC.arrangedObjects as AnyObject).count)
        let indexSet : NSIndexSet = NSIndexSet(indexesIn: range)
        
        companyAC.remove(atArrangedObjectIndexes: indexSet as IndexSet)
        
        for comp in CDM.compArray {
            
            self.companyAC.addObject(comp)
        }
        
        companyTable.reloadData()
        
        companyTable.sortDescriptors = [NSSortDescriptor(key: "company", ascending: true, selector: #selector(NSString.compare(_:)))]
        
        
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
        let comp:CompanyStruct = CDM.compArray[companyTable.selectedRow]
        //Define delID as the value from ddict for key idCompany ie it returns the value of idCompany at the row selected
        let delID = comp.idCompany
        
        //Need to check whether contacts are attached to company
        
        var ind99 = 2
        
        ind99 = CDM.checkContacts(ic: delID)
        
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
            CDM.deleteRecord(delID)
            //Get the
            let delIndex = companyTable.selectedRow
            //Remove record from compArray
            CDM.compArray.remove(at: delIndex)
            self.companyAC.remove(atArrangedObjectIndex: delIndex)
            //Reload the table to refresh after delete
            companyTable.reloadData()
            
            }
        
    }
    
    
}
