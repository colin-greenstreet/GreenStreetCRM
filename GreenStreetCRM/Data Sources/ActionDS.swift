//
//  ActionDS.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 20/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa
import SQLite3

class ActionDataModel {
    
    static let actionSharedInstance = ActionDataModel()
    
    var db: OpaquePointer?
    
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("GreenStreetCRM.db")
    
    let selectActStatement = "SELECT IDACTION, Action.IDOPPORTUNITY, COMPANY, LISTNAME, OPPNAME, ACTIONname, ACTIONDUEDISP, ACTIONSTATUS, actiondueraw FROM Action INNER JOIN opportunity ON Opportunity.IDopportunity = Action.IDopportunity INNER JOIN company ON company.IDcompany = opportunity.Idcompany inner join contact on contact.idcontact = opportunity.idcontact order by actiondueraw;"
    
    let deleteActStatement = "delete from action where idaction = ?;"
    
    let maxSelectStatement = "select max(idaction) from action;"
    
    let insertStatement = "insert into action (idaction, idopportunity, actionname, actionduedisp, actiondueraw, actionstatus ) values (?, ?, ?, ?, ?, ?);"
    
    let getContactPrimarySelect = "select idcontact from contact where listname = ?;"
    
    let getCompPrimarySelect = "select idcompany from company where company = ?;"
    
    let getSingleAction = "SELECT IDACTION, ACTION.IDOPPORTUNITY, COMPANY, LISTNAME, OPPNAME, ACTIONname, ACTIONDUEDISP, ACTIONDUERAW, ACTIONSTATUS FROM Action INNER JOIN opportunity ON Opportunity.IDopportunity = Action.IDopportunity INNER JOIN company ON company.IDcompany = opportunity.Idcompany inner join contact on contact.idcontact = opportunity.idcontact WHERE IDaction = ?;"
    
    let updateString = "update action set actionname = ?, actionduedisp = ?, actiondueraw = ?, actionstatus = ? where idaction = ?;"
    
    let getActionsForOpp = "SELECT IDACTION, ACTION.IDOPPORTUNITY, COMPANY, LISTNAME, OPPNAME, ACTIONname, ACTIONDUEdisp, ACTIONSTATUS, actiondueraw FROM Action INNER JOIN opportunity ON Opportunity.IDopportunity = Action.IDopportunity INNER JOIN company ON company.IDcompany = opportunity.Idcompany inner join contact on contact.idcontact = opportunity.idcontact where action.idopportunity = ? order by actiondueraw;"
    
     
    var actArray: NSMutableArray = []
    
    var nxtIdAction: Int32 = 0
    
    private init() {
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            
            print("File \(fileURL) opened OK")
        } else {
            
            print("File \(fileURL) failed to open")
        }
       
        getAction()
}

    //Function to get the next number to be used when performing an insert
    func getMaxID() -> Int32
    {
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, maxSelectStatement, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let ida: Int32 = sqlite3_column_int(queryStatement, 0)
                nxtIdAction = ida + 1
                
            }
            
            
        }
        
        sqlite3_finalize(queryStatement)
        
        return nxtIdAction
        
    }
    
    
    //Function to get all actions from db
    func getAction() {
        
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, selectActStatement, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let acid = sqlite3_column_int(queryStatement, 0)
                let acio = sqlite3_column_int(queryStatement, 1)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 2)
                let company = String(cString: queryResultCol1!)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 3)
                let listName = String(cString: queryResultCol2!)
                let queryResultCol3 = sqlite3_column_text(queryStatement, 4)
                let oppName = String(cString: queryResultCol3!)
                let queryResultCol4 = sqlite3_column_text(queryStatement, 5)
                let actionName = String(cString: queryResultCol4!)
                let queryResultCol5 = sqlite3_column_text(queryStatement, 6)
                let actionDue = String(cString: queryResultCol5!)
                let queryResultCol6 = sqlite3_column_text(queryStatement, 7)
                let actionStatus = String(cString: queryResultCol6!)
                
                
                let dict = ["idAction": acid, "idOpportunity": acio, "actionCompany": company, "actionContact": listName, "actionOpp": oppName, "actionName": actionName, "actionDue": actionDue, "actionStatus": actionStatus] as [String : Any]
                actArray.add(dict)
            }
        }
        
        sqlite3_finalize(queryStatement)
        
    }
    
    
    //Function to get all actions from db for a specified opportunity
    func getActionForOpp(opp: Int) {
        
        actArray.removeAllObjects()
        
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, getActionsForOpp, -1, &queryStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(queryStatement, 1, Int32(opp))
            
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let acid = sqlite3_column_int(queryStatement, 0)
                let acio = sqlite3_column_int(queryStatement, 1)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 2)
                let company = String(cString: queryResultCol1!)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 3)
                let listName = String(cString: queryResultCol2!)
                let queryResultCol3 = sqlite3_column_text(queryStatement, 4)
                let oppName = String(cString: queryResultCol3!)
                let queryResultCol4 = sqlite3_column_text(queryStatement, 5)
                let actionName = String(cString: queryResultCol4!)
                let queryResultCol5 = sqlite3_column_text(queryStatement, 6)
                let actionDue = String(cString: queryResultCol5!)
                let queryResultCol6 = sqlite3_column_text(queryStatement, 7)
                let actionStatus = String(cString: queryResultCol6!)
                
                
                let dict = ["idAction": acid, "idOpportunity": acio, "actionCompany": company, "actionContact": listName, "actionOpp": oppName, "actionName": actionName, "actionDue": actionDue, "actionStatus": actionStatus] as [String : Any]
                actArray.add(dict)
            }
        }
        
        sqlite3_finalize(queryStatement)
    }
    
    //method to delete record
    //Accepts an id parameter
    func deleteRecord(_ id: Int) {
        
        var deleteStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, deleteActStatement, -1, &deleteStatement, nil) == SQLITE_OK {
            
            
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                
                print("Successfully deleted row with idOpp \(id).")
            } else {
                print("Could not deleted row.")
            } } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(deleteStatement)
        
        
    }
    
    
    func getSingleAction(ia: Int) -> ActionStruct {
        
        var queryStatement: OpaquePointer? = nil
        var act = ActionStruct.init(idAction: 0, idOpportunity: 0, company: "", listName: "", oppName: "", actionName: "", actionDueDisp: "", actionDueRaw: 0, actionStatus: "")
        
        if sqlite3_prepare_v2(db, getSingleAction, -1, &queryStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(queryStatement, 1, Int32(ia))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let ia = sqlite3_column_int(queryStatement, 0)
                let io = sqlite3_column_int(queryStatement, 1)
                let actionDueRaw = sqlite3_column_double(queryStatement, 7)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 2)
                let companyName = String(cString: queryResultCol1!)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 3)
                let listName = String(cString: queryResultCol2!)
                let queryResultCol3 = sqlite3_column_text(queryStatement, 4)
                let oppName = String(cString: queryResultCol3!)
                let queryResultCol4 = sqlite3_column_text(queryStatement, 5)
                let actionName = String(cString: queryResultCol4!)
                let queryResultCol5 = sqlite3_column_text(queryStatement, 6)
                let actionDueString = String(cString: queryResultCol5!)
                let queryResultCol6 = sqlite3_column_text(queryStatement, 8)
                let actionStatus = String(cString: queryResultCol6!)
                
                
                act.idAction = Int(ia)
                act.idOpportunity = Int(io)
                act.company = companyName
                act.listName = listName
                act.oppName = oppName
                act.actionName = actionName
                act.actionDueDisp = actionDueString
                act.actionStatus = actionStatus
                act.actionDueRaw = actionDueRaw
                
            }
        }
        
        sqlite3_finalize(queryStatement)
        
        return act
        
    }
    
    //Function to insert a action based on a action struct passed in as parameter
    func insert(action: ActionStruct, mode: Int) {
        var insStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, insertStatement, -1, &insStatement, nil) == SQLITE_OK {
            
            let ia: Int32 = Int32(action.idAction)
            let ido: Int32 = Int32(action.idOpportunity)
            let an: NSString = action.actionName as NSString
            let actionDueDisp: NSString = action.actionDueDisp as NSString
            let actionDueRaw: Double = Double(action.actionDueRaw)
            let actionStatus: NSString = action.actionStatus as NSString
            
            
            
            sqlite3_bind_int(insStatement, 1, ia)
            sqlite3_bind_int(insStatement, 2, ido)
            sqlite3_bind_text(insStatement, 3, an.utf8String, -1, nil)
            sqlite3_bind_text(insStatement, 4, actionDueDisp.utf8String, -1, nil)
            sqlite3_bind_double(insStatement, 5, actionDueRaw)
            sqlite3_bind_text(insStatement, 6, actionStatus.utf8String, -1, nil)
            
            
            if sqlite3_step(insStatement) == SQLITE_DONE {
                
                
            }
            sqlite3_finalize(insStatement)
            
            actArray.removeAllObjects()
            
            if mode == 4 {
                //Get ball actions
                getAction()
            } else {
                getActionForOpp(opp: Int(ido))
            }
            
            
            
        }
        
    }
    
    func updateAction(action: ActionStruct) {
        
        var updateStatement: OpaquePointer? = nil
        let ia: Int32 = Int32(action.idAction)
        let an: NSString = action.actionName as NSString
        let actionDueDisp: NSString = action.actionDueDisp as NSString
        let actionDueRaw: Double = action.actionDueRaw
        let actionStatus: NSString = action.actionStatus as NSString
        
        
        if sqlite3_prepare_v2(db, updateString, -1, &updateStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(updateStatement, 5, ia)
            sqlite3_bind_text(updateStatement, 1, an.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, actionDueDisp.utf8String, -1, nil)
            sqlite3_bind_double(updateStatement, 3, actionDueRaw)
            sqlite3_bind_text(updateStatement, 4, actionStatus.utf8String, -1, nil)
            
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                
                print("Successfully updated row ")
            } else {
                print("Could not update row.")
            } } else {
            print("update statement could not be prepared.")
            
        }
        sqlite3_finalize(updateStatement)
        
        actArray.removeAllObjects()
        getAction()
        
    }
    
    
    
    //End class
}
