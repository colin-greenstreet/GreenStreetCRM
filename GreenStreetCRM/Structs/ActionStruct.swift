//
//  ActionStruct.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 19/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import AppKit

//Declaring a new struct for Action

public class ActionStruct: NSObject {
    @objc var idAction: Int
    @objc var idOpportunity: Int
    @objc var company: String
    @objc var listName: String
    @objc var oppName: String
    @objc var actionName: String
    @objc var actionDueDisp: String
    @objc var actionDueRaw: Double
    @objc var actionStatus: String
    
    init(idAction: Int, idOpportunity: Int, company: String, listName: String, oppName: String, actionName: String, actionDueDisp: String, actionDueRaw: Double, actionStatus: String) {
        
        self.idAction = idAction
        self.idOpportunity = idOpportunity
        self.company = company
        self.listName = listName
        self.oppName = oppName
        self.actionName = actionName
        self.actionDueDisp = actionDueDisp
        self.actionDueRaw = actionDueRaw
        self.actionStatus = actionStatus
        
    }
}
