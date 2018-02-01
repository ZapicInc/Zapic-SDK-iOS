//
//  ZapicContact.swift
//  Zapic
//
//  Created by Daniel Sarfati on 1/31/18.
//  Copyright © 2018 zapic. All rights reserved.
//

import Foundation
import Contacts

struct ZapicContact {
  let firstName: String
  let lastName: String
  var phoneNumbers = [String]()
  var emailAddresses = [String]()

  init(_ contact: CNContact) {
    self.firstName = contact.givenName
    self.lastName = contact.familyName

    for phone in contact.phoneNumbers {
      phoneNumbers.append(phone.value.stringValue)
    }

    for email in contact.emailAddresses {
      emailAddresses.append(String(email.value))
    }
  }
}
