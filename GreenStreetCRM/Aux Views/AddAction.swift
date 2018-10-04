//
//  AddAction.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 19/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa

class AddAction: NSViewController, NSComboBoxDataSource, NSComboBoxDelegate {
    
    
    @IBOutlet weak var cmbOpportunity: NSComboBox!
    
    @IBOutlet weak var txtActionName: NSTextField!
    
    @IBOutlet weak var dpActionDue: NSDatePicker!
    
    @IBOutlet weak var chkActionStatus: NSButton!
    
    @IBOutlet weak var lblActionDueString: NSTextField!
    
    
    //Initialise a variable repObj that will be set by the representedobject and can then be tested to control mode and if edit which idCompany record is to be edited
    var repObj = [Int]()
    
    //Define delegate that is a reference back to calling view controller. It is set when segue fired
    var delegate: AnyObject?
    
    var ia = 0
    
    //Define variable that will be used to hold the idOpportunity associated with the opportunity selected from Combobox
    var ido = 0
    
    var oppIndex: Array<String> = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        cmbOpportunity.usesDataSource = true
        //Tell combobox that this class view controller will provide delegate
        cmbOpportunity.dataSource = self
        cmbOpportunity.delegate = self
        
        //Populate the array for loading to combobox
        oppIndex = (delegate as! ActionTableView).getOpportunity()
        
        
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return oppIndex.count
        
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return oppIndex[index]
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
            
        //Case 1 is add datePicker already initialised to today in view did load
        case 1:
            dpActionDue.dateValue = Date()
            
            chkActionStatus.state = NSControl.StateValue.off
            
            if repObj[3] == 3 {
                
                let opp = (delegate as! ActionTableView).getSingleOpportunity(io: repObj[2])
                cmbOpportunity.isSelectable = false
                cmbOpportunity.stringValue = opp.oppDesc
            }
            
        //case 2 is edit
        case 2:
            
            //Need to get existing action record for the table row selected
            let action = (delegate as! ActionTableView).getSingleAction(ia: repObj[1])
            
            cmbOpportunity.isSelectable = false
            cmbOpportunity.stringValue = action.oppName
            txtActionName.stringValue = action.actionName
            lblActionDueString.stringValue = action.actionDueDisp
            dpActionDue.dateValue = Date(timeIntervalSinceReferenceDate: action.actionDueRaw)
            
            if action.actionStatus == "To Do" {
                
                chkActionStatus.state = NSControl.StateValue.off
                
            } else {
                
                chkActionStatus.state = NSControl.StateValue.on
                
            }
            
        //Default is do nothing
        default:
            break
        }
    }
    
    
    @IBAction func btnAddAction(_ sender: Any) {
        
        //Set value of actionStatus based on checkBox
        var actS = ""
        if chkActionStatus.state == NSControl.StateValue.off {
            
            actS = "To Do"
            
        } else {
            
            actS = "Done"
        }
        
        //Test on repObj index 0 which is the mode
        switch repObj[0] {
            
        //Case 1 is add
        case 1:
            
            //Define ia is the idAction to be used on the insert by calling the data source get next function via the view controller as delegate
            ia = (delegate as! ActionTableView).getNxtKey()
            
            //Get the idOpportunity from combobox selection
            ido = (delegate as! ActionTableView).getPrimaryKey(opportunity: cmbOpportunity.stringValue)
            
            
            //initialise the action struct to be passed into insert function
            let act = ActionStruct(idAction: ia, idOpportunity: ido, company: "", listName: "", oppName: "", actionName: txtActionName.stringValue, actionDueDisp: lblActionDueString.stringValue, actionDueRaw: dpActionDue.dateValue.timeIntervalSinceReferenceDate, actionStatus: actS)
            
            (delegate as! ActionTableView).addRecord(action: act, mode: repObj[3])
            
            
            dismiss(self)
            
            
        //case 2 is edit
        case 2:
            
            let act = ActionStruct(idAction: repObj[1], idOpportunity: repObj[2], company: "", listName: "", oppName: "", actionName: txtActionName.stringValue, actionDueDisp: lblActionDueString.stringValue, actionDueRaw: dpActionDue.dateValue.timeIntervalSinceReferenceDate, actionStatus: actS)
            (delegate as! ActionTableView).updateAction(action: act, mode: repObj[3])
            
            dismiss(self)
            
        //Default is do nothing
        default:
            break
        }
        
    }
        
        
    
    
    @IBAction func btnCancel(_ sender: Any) {
        
        dismiss(self)
    }
    
    @IBAction func dpActionDue(_ sender: NSDatePicker) {
        
        let DF = DateFormatter()
        
        DF.dateFormat = "d MMM, yyyy"
        
        DF.timeZone = NSTimeZone.local
        
        lblActionDueString.stringValue = DF.string(from: sender.dateValue)
    }
    
    //End class
}
