//
//  ActionTableView.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 19/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa

class ActionTableView: NSViewController {

    @IBOutlet var actionAC: NSArrayController!
    
    @IBOutlet weak var actionTable: NSTableView!
        
    @IBOutlet weak var oppLabel: NSTextField!
    
    //Create an instance of the action datasource class
    let ADM = ActionDataModel.actionSharedInstance
    
    //Create an instance of the opportunity datasource class
    let ODM = OppDataModel.oppSharedInstance
    
    //Define an array that will have index 0 = mode (1=add, 2=change, 3=Single opportunity and 4=All actions) and index 1 = the idAction of the record to be changed (or 0 if in add mode) or the idOpportunity if in add mode and called from opportunity view controller
    var repObj = [4, 0]
    
    var mode = 4
    
    //Define delegate that is a reference back to calling view controller. It is set when segue fired
    var delegate: AnyObject?
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            
            //set repObj to the representedobject passed from the view controller NB there will be no repObj passed if called from menu and therefore repObj[0] = 4
            repObj = representedObject as! [Int]
            
            if repObj[0] == 3 {
                
                mode = 3
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        for act in ADM.actArray {
            
            self.actionAC.addObject(act)
        }
        
        actionTable.sortDescriptors = [NSSortDescriptor(key: "actionDueRaw", ascending: true, selector: #selector(NSString.compare(_:))), NSSortDescriptor(key: "company", ascending: true, selector: #selector(NSString.compare(_:)))]
        
    }
    
    override func viewWillAppear() {
        
        //Test on repObj index 0 which is the mode
        switch repObj[0] {
            
        //Case 3 is called from opportunities - restrict actions to that opportunity
        case 3:
            
            
            ADM.actArray = (delegate as! ViewController).getActionForOpp(io: repObj[1])
            
            let range : NSRange = NSMakeRange(0, (actionAC.arrangedObjects as AnyObject).count)
            let indexSet : NSIndexSet = NSIndexSet(indexesIn: range)
            
            actionAC.remove(atArrangedObjectIndexes: indexSet as IndexSet)
            
            for act in ADM.actArray {
                
                self.actionAC.addObject(act)
            }
            
            actionTable.reloadData()
            
            actionTable.sortDescriptors = [NSSortDescriptor(key: "actionDueRaw", ascending: true, selector: #selector(NSString.compare(_:)))]
            
            
            actionTable.sortDescriptors = [NSSortDescriptor(key: "actionDueRaw", ascending: true, selector: #selector(NSString.compare(_:))), NSSortDescriptor(key: "company", ascending: true, selector: #selector(NSString.compare(_:)))]
            
            //Define constant ddict as an NSDictionary and set to the ADM instance of the DataModel class at the row selected in the table. ADM needs to be cast as an NSDictionary.
            let act:ActionStruct = ADM.actArray[0]
            
            if act.idAction != 0 {
                
                //Define oppName as the value from act for key oppName ie it returns the value of idCompany at the row selected
                let oppName = act.oppName
                oppLabel.stringValue = "Showing: \(oppName)"
                
            } else {
                
                //The Opportunity does not yet have any actions so need to get the Opportunity record in order to load name into header
                let opp: OpportunityStruct = getSingleOpportunity(io: repObj[1])
                let oppName = opp.oppDesc
                oppLabel.stringValue = "Showing: \(oppName)"
                
            }
            
            
            
        //Default is that view was called from menu and therefore all actions should be shown
        default:
            oppLabel.stringValue = "Showing: Actions for All Opportunities"
            
            let range : NSRange = NSMakeRange(0, (actionAC.arrangedObjects as AnyObject).count)
            let indexSet : NSIndexSet = NSIndexSet(indexesIn: range)
            
            actionAC.remove(atArrangedObjectIndexes: indexSet as IndexSet)
            ADM.actArray.removeAll()
            
            ADM.getAction()
            for act in ADM.actArray {
                
                self.actionAC.addObject(act)
            }
            
            actionTable.reloadData()
            
            actionTable.sortDescriptors = [NSSortDescriptor(key: "actionDueRaw", ascending: true, selector: #selector(NSString.compare(_:))), NSSortDescriptor(key: "company", ascending: true, selector: #selector(NSString.compare(_:)))]
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
                let act:ActionStruct = ADM.actArray[actionTable.selectedRow]
                //Define chgID as the value from cdict for key idAction ie it returns the value of idCompany at the row selected
                let actID = act.idAction
                let oppID = act.idOpportunity
                                
                //Set repObj to edit mode and pass idAction
                repObj = [2, actID, oppID, mode]
                
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
    
    func updateAction(action: ActionStruct, mode: Int) {
        ADM.updateAction(action: action, mode: mode)
        
        let range : NSRange = NSMakeRange(0, (actionAC.arrangedObjects as AnyObject).count)
        let indexSet : NSIndexSet = NSIndexSet(indexesIn: range)
        
        actionAC.remove(atArrangedObjectIndexes: indexSet as IndexSet)
        
        
        for act in ADM.actArray {
            
            self.actionAC.addObject(act)
        }
        
        actionTable.reloadData()
        
    }
    
    //The get singleaction function will be called by the popover to populate the fields ready for edit
    func getSingleAction(ia: Int) -> ActionStruct {
        
        let action = ADM.getSingleAction(ia: ia)
        return action
        
    }
    
    @IBAction func btnDeleteAction(_ sender: Any) {
        
        //Define constant ddict as an NSDictionary and set to the ADM instance of the DataModel class at the row selected in the table. ADM needs to be cast as an NSDictionary.
        let act:ActionStruct = ADM.actArray[actionTable.selectedRow]
        //Define delID as the value from ddict for key idAction ie it returns the value of idAction at the row selected
        let delID = act.idAction
        //Call the delete function on ADM passing in delID as parameter. The delete function will delete the record with this idAction value
        ADM.deleteRecord(delID)
        //Get the
        let delIndex = actionTable.selectedRow
        //Remove record from actArray
        ADM.actArray.remove(at: delIndex)
        //Reload the table to refresh after delete
        self.actionAC.remove(atArrangedObjectIndex: delIndex)
        actionTable.reloadData()
    }
    
    //The get next primary key that will be called by the popover
    
    func getNxtKey() -> Int {
        
        return Int(ADM.getMaxID())
    }
    
    //The add record method that will be called from the popover
    func addRecord(action: ActionStruct, mode: Int) {
        
        ADM.insert(action: action, mode: mode)
        
        let range : NSRange = NSMakeRange(0, (actionAC.arrangedObjects as AnyObject).count)
        let indexSet : NSIndexSet = NSIndexSet(indexesIn: range)
        
        actionAC.remove(atArrangedObjectIndexes: indexSet as IndexSet)
       
        for act in ADM.actArray {
            
            self.actionAC.addObject(act)
        }
        
        actionTable.reloadData()
        
        actionTable.sortDescriptors = [NSSortDescriptor(key: "actionDueRaw", ascending: true, selector: #selector(NSString.compare(_:))), NSSortDescriptor(key: "company", ascending: true, selector: #selector(NSString.compare(_:)))]
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
    
    func getSingleOpportunity(io: Int) -> OpportunityStruct {
        
        let opp = ODM.getSingleOpportunity(io: io)
        
        return opp
    }
    
    //end class
}
