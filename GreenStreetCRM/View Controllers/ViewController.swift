//
//  ViewController.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 03/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    //Create an instance of the contact datasource class
    let CDM = ContDataModel.contSharedInstance
    
    //Create an instance of the company datasource class
    let CODM = CompDataModel.compSharedInstance
    
    //Create an instance of the company datasource class
    let ADM = ActionDataModel.actionSharedInstance
    
    @IBOutlet weak var opportunityTable: NSTableView!
    
    @IBOutlet var opportunityAC: NSArrayController!
    
    
    //Create an instance of the datasource class
    let ODM = OppDataModel.oppSharedInstance
    
    //Define an array that will have index 0 = mode (1=add, 2=change) and index 1 = the idCompany of the record to be changed (or 0 if in add mode)
    var repObj = [Int]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        for opp in ODM.oppArray {
            
            self.opportunityAC.addObject(opp)
        }
        
        opportunityTable.sortDescriptors = [NSSortDescriptor(key: "company", ascending: true, selector: #selector(NSString.compare(_:)))]
    }
    
    //Prepare for segue to add or edit opportunity
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        //Define constant strSegue which is equal to the segue identifier
        if let strSegue = segue.identifier {
            
            //Test strSegue and if it is the addCompany button
            switch strSegue.rawValue {
                
            //If adding a opportunity
            case "addOpportunity":
                //Set repObj to add mode and no idOpportunity
                repObj = [1, 0]
                
                //Set the destination controller and pass the representedobject as repObj
                let auxView = segue.destinationController as! AddOpportunityController
                auxView.delegate = self
                auxView.representedObject = repObj
                
                
            //If changing a opportunity
            case "chgOpportunity":
                //Define constant cdict as an NSDictionary and set to the ODM instance of the DataModel class at the row selected in the table. DM needs to be cast as an NSDictionary.
                let opp:OpportunityStruct = ODM.oppArray[opportunityTable.selectedRow]
                //Define chgID as the value from cdict for key idOpportunity ie it returns the value of idOpportunity at the row selected
                let chgID = opp.idOpportunity
                //Set repObj to edit mode and pass idCompany
                repObj = [2, chgID]
                
                //Set the destination controller and pass the representedobject as repObj
                let auxView = segue.destinationController as! AddOpportunityController
                auxView.delegate = self
                auxView.representedObject = repObj
                
                //Ifsegue to actions
            
            
            case "actionTV":
                
                //Define constant cdict as an NSDictionary and set to the ODM instance of the DataModel class at the row selected in the table. DM needs to be cast as an NSDictionary.
                let opp:OpportunityStruct = ODM.oppArray[opportunityTable.selectedRow]
                //Define chgID as the value from cdict for key idOpportunity ie it returns the value of idOpportunity at the row selected
                let oppID = opp.idOpportunity
                //Set repObj to action mode and pass idOpportunity
                repObj = [3, oppID]
                
                //Set the destination controller and pass the representedobject as repObj
                let auxView = segue.destinationController as! ActionTableView
                auxView.delegate = self
                auxView.representedObject = repObj
                
            //Else
            default:
                //Do nothing
                break
            }
            
        }
    }


    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    //The get singleopportunity function will be called by the popover to populate the fields ready for edit
    func getSingleOpportunity(io: Int) -> OpportunityStruct {
        
        let opp = ODM.getSingleOpportunity(io: io)
        return opp
        
    }
    
    @IBAction func btnDeleteOpportunity(_ sender: Any) {
        
        //Define  opp as an OpportunityStruct and set to the ODM instance of the DataModel class at the row selected in the table.
        let opp:OpportunityStruct = ODM.oppArray[opportunityTable.selectedRow]
        //Define delID as the value from opp for  idOpportunity ie it returns the value of idOpportunity at the row selected
        let delID = opp.idOpportunity
        
        //Need to check whether actions are attached to opportunity
        var ind99 = 2
        
        ind99 = ODM.checkActions(ic: delID)
        
        if ind99 == 1 {
            
            //Create an alert to warn of actions that prevent opportunity deletion
            let alert: NSAlert = NSAlert()
            alert.messageText = "Opportunity cannot be deleted as it has Actions"
            alert.informativeText = "All Actions need to be deleted before deleting the Opportunity"
            alert.alertStyle = NSAlert.Style.critical
            alert.addButton(withTitle: "OK")
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
            
        } else {
          
        //Call the delete function on ODM passing in delID as parameter. The delete function will delete the record with this idOpportunity value
        ODM.deleteRecord(delID)
        //Get the
        let delIndex = opportunityTable.selectedRow
        //Remove record from opArray
        ODM.oppArray.remove(at: delIndex)
        //Reload the table to refresh after delete
        self.opportunityAC.remove(atArrangedObjectIndex: delIndex)
        opportunityTable.reloadData()
        }
    }
    
    @IBAction func btnToDo(_ sender: Any) {
    }
    
    //The get company function will be called by the popover to populate the company combobox
    func getCompany() -> Array<String> {
        
        let compIndex = CODM.compIndex
        return compIndex
        
    }
    
    //The get contact function will be called by the popover to populate the contact combobox
    func getContact() -> Array<String> {
        
        let contIndex = CDM.contIndex
        return contIndex
        
    }
    
    //The get next primary key that will be called by the popover
    
    func getNxtKey() -> Int {
        
        return Int(ODM.getMaxID())
    }
    
    //The getPrimaryKey will be called by the popover to populate idCompany
    
    func getPrimaryKeyComp(company: String) -> Int {
        
        let idc = CODM.getPrimaryKey(company: company)
        
        return idc
    }
    
    //The getPrimaryKey will be called by the popover to populate idContact
    
    func getPrimaryKeyCont(listName: String) -> Int {
        
        let idcn = CDM.getPrimaryKey(listName: listName)
        
        return idcn
    }
    
    func addOpportunity(opportunity: OpportunityStruct) {
        ODM.insert(opportunity: opportunity)
        
        let range : NSRange = NSMakeRange(0, (opportunityAC.arrangedObjects as AnyObject).count)
        let indexSet : NSIndexSet = NSIndexSet(indexesIn: range)
        
        opportunityAC.remove(atArrangedObjectIndexes: indexSet as IndexSet)
        
        for opp in ODM.oppArray {
            
            self.opportunityAC.addObject(opp)
        }
        
        opportunityTable.reloadData()
        
        opportunityTable.sortDescriptors = [NSSortDescriptor(key: "company", ascending: true, selector: #selector(NSString.compare(_:)))]
    }
    
    //The update contact function will be called by the popover
    
    func updateOpportunity(opportunity: OpportunityStruct) {
        ODM.updateOpportunity(opportunity: opportunity)
        
        
        let range : NSRange = NSMakeRange(0, (opportunityAC.arrangedObjects as AnyObject).count)
        let indexSet : NSIndexSet = NSIndexSet(indexesIn: range)
        
        opportunityAC.remove(atArrangedObjectIndexes: indexSet as IndexSet)
        
        for opp in ODM.oppArray {
            
            self.opportunityAC.addObject(opp)
        }
        
        opportunityTable.reloadData()
        
        opportunityTable.sortDescriptors = [NSSortDescriptor(key: "company", ascending: true, selector: #selector(NSString.compare(_:)))]
        
    }
    
    
    //The get action function will be called by the popover to populate the action tableview when segue from opportunities to do button
    func getActionForOpp(io: Int) -> Array<ActionStruct>{
        
        ADM.getActionForOpp(opp: io)
        let actArray = ADM.actArray
        return actArray
        
    }
    
    //The get contacts for company function will be called by the popover to reload contact combobox with the contacts for the selected company
    func getContactForCompany(ic: Int) -> Array<String>{
        
        
        let contIndex = CDM.getContactForCompany(idCompany: ic)
        return contIndex
        
    }
    
    //End of class
    }

