//
//  ActionTableView.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 19/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa

class ActionTableView: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var actionTable: NSTableView!
    
    @IBOutlet weak var oppLabel: NSTextField!
    
    //Create an instance of the action datasource class
    let ADM = ActionDataModel.actionSharedInstance
    
    //Create an instance of the opportunity datasource class
    let ODM = OppDataModel.oppSharedInstance
    
    //Define an array that will have index 0 = mode (1=add, 2=change, 3=Single opportunity and 4=All actions) and index 1 = the idAction of the record to be changed (or 0 if in add mode) or the idOpportunity if in add mode and called from opportunity view controller
    var repObj = [4, 0]
    
    //Define delegate that is a reference back to calling view controller. It is set when segue fired
    var delegate: AnyObject?
    
    //Call the func no of rows in data source that is required by the NSTableViewDataSource protocol
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ADM.actArray.count
    }
    
    //Define the function that will get the data for each cell for each row.
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        //Define constant dict as an NSDictionary and set to the DM instance of the DataModel class at the row being loaded into the table. DM needs to be cast as an NSDictionary. row is passed in as a parameter by the OS
        let adict:NSDictionary = ADM.actArray[row] as! NSDictionary
        
        //Define strKey as the column identifier for the column being loaded. Column being loaded is passed in as a parameter by the OS
        let strKey = (tableColumn?.identifier)!
        
        //method will return the value from dict (which is loaded from CDM.compArray) for the key that is equal to the column identifier which was loaded to strKey
        return adict.value(forKey: strKey.rawValue)
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            
            //set repObj to the representedobject passed from the view controller NB there will be no repObj passed if called from menu and therefore repObj[0] = 4
            repObj = representedObject as! [Int]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        actionTable.dataSource = self
        actionTable.delegate = self
    }
    
    override func viewWillAppear() {
        
        //Test on repObj index 0 which is the mode
        switch repObj[0] {
            
        //Case 3 is called from opportunities - restrict actions to that opportunity
        case 3:
            
            
            ADM.actArray = (delegate as! ViewController).getActionForOpp(io: repObj[1])
            actionTable.reloadData()
            //Define constant ddict as an NSDictionary and set to the ADM instance of the DataModel class at the row selected in the table. ADM needs to be cast as an NSDictionary.
            let ddict:NSDictionary = ADM.actArray[0] as! NSDictionary
            //Define oppName as the value from ddict for key oppName ie it returns the value of idCompany at the row selected
            let oppName = ddict["actionOpp"]
            oppLabel.stringValue = "Showing: \(oppName ?? "")"
            
        //Default is that view was called from menu and therefore all actions should be shown
        default:
            oppLabel.stringValue = "Showing: Actions for All Opportunities"
            ADM.actArray.removeAllObjects()
            ADM.getAction()
            actionTable.reloadData()
        }
    }
    
    
    
    //Prepare for segue to add or edit action
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
               
        //Define constant strSegue which is equal to the segue identifier
        if let strSegue = segue.identifier {
            
            //Test strSegue and if it is the addCompany button
            switch strSegue.rawValue {
                
            //If adding an action
            case "addAction":
                
                //Store inbound repobj mode - either 4=All actions or 3=Actions for an opportunity
                let mode = repObj[0]
                
                let oppID = repObj[1]
                
                //Set repObj to add mode and pass idOpportunity
                repObj = [1, 0, oppID, mode]
                
                //Set the destination controller and pass the representedobject as repObj
                let auxView = segue.destinationController as! AddAction
                auxView.delegate = self
                auxView.representedObject = repObj
                
                
            //If changing a action
            case "chgAction":
                //Define constant cdict as an NSDictionary and set to the ADM instance of the DataModel class at the row selected in the table. DM needs to be cast as an NSDictionary.
                let cdict:NSDictionary = ADM.actArray[actionTable.selectedRow] as! NSDictionary
                //Define chgID as the value from cdict for key idAction ie it returns the value of idCompany at the row selected
                let actID = cdict["idAction"]
                let oppID = cdict["idOpportunity"]
                                
                //Set repObj to edit mode and pass idAction
                repObj = [2, actID, oppID] as! [Int]
                
                //Set the destination controller and pass the representedobject as repObj
                let auxView = segue.destinationController as! AddAction
                auxView.delegate = self
                auxView.representedObject = repObj
                
            //Else
            default:
                //Do nothing
                break
            }
            
        }
    }
    
    //The updateaction function will be called by the popover
    
    func updateAction(action: ActionStruct) {
        ADM.updateAction(action: action)
        actionTable.reloadData()
        
    }
    
    //The get singleaction function will be called by the popover to populate the fields ready for edit
    func getSingleAction(ia: Int) -> ActionStruct {
        
        let action = ADM.getSingleAction(ia: ia)
        return action
        
    }
    
    @IBAction func btnDeleteAction(_ sender: Any) {
        
        //Define constant ddict as an NSDictionary and set to the ADM instance of the DataModel class at the row selected in the table. ADM needs to be cast as an NSDictionary.
        let ddict:NSDictionary = ADM.actArray[actionTable.selectedRow] as! NSDictionary
        //Define delID as the value from ddict for key idAction ie it returns the value of idAction at the row selected
        let delID = ddict["idAction"]
        //Call the delete function on ADM passing in delID as parameter. The delete function will delete the record with this idAction value
        ADM.deleteRecord(delID as! Int)
        //Get the
        let delIndex = actionTable.selectedRow
        //Remove record from actArray
        ADM.actArray.removeObject(at: delIndex)
        //Reload the table to refresh after delete
        actionTable.reloadData()
    }
    
    //The get next primary key that will be called by the popover
    
    func getNxtKey() -> Int {
        
        return Int(ADM.getMaxID())
    }
    
    //The add record method that will be called from the popover
    func addRecord(action: ActionStruct, mode: Int) {
        
        ADM.insert(action: action, mode: mode)
        
        
        //Reload the table to refresh after add
        actionTable.reloadData()
    }
    
    //The get company function will be called by the popover to populate the company combobox
    func getOpportunity() -> Array<String> {
        
        let oppIndex = ODM.oppIndex
        return oppIndex
        
    }
    
    //The getPrimaryKey will be called by the popover to populate idOpportunity
    
    func getPrimaryKey(opportunity: String) -> Int {
        
        let ido = ODM.getPrimaryKey(oppName: opportunity)
        
        return ido
    }
    
    //end class
}
