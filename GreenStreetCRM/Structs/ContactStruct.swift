//
//  ContactStruct.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 15/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import AppKit

//Declaring a new struct for Contact

public class ContactStruct: NSObject {
    @objc var idContact: Int
    @objc var idCompany: Int
    @objc var company: String
    @objc var firstName: String
    @objc var lastName: String
    @objc var listName: String
    @objc var email: String?
    @objc var DD: String?
    @objc var mobile: String?
    
    init(idContact: Int, idCompany: Int, company: String, firstName: String, lastName: String, listName: String, email: String, DD: String, mobile: String) {
        self.idContact = idContact
        self.idCompany = idCompany
        self.company = company
        self.firstName = firstName
        self.lastName = lastName
        self.listName = listName
        self.email = email
        self.DD = DD
        self.mobile = mobile
    }
}
