//
//  ContactsController.swift
//  Zapic
//
//  Created by Daniel Sarfati on 1/31/18.
//  Copyright © 2018 zapic. All rights reserved.
//

import Foundation
import Contacts

extension ZapicViewController: ContactsController {

  func getContacts() {
//    getContacts {contacts in
//
//      if let contacts = contacts {
//        self.send(type: .setContacts, payload: contacts)
//      } else {
//        self.send(type: .setContacts, payload: "Unable to get contacts", isError: true)
//      }
//    }
  }
//
//  private func getContacts(completionHandler: @escaping (_ contacts: [[String: Any]]?) -> Void) {
//
//    requestForAccess { (accessGranted) -> Void in
//      if accessGranted {
//
//        let contacts = self.retrieveContacts()
//        let zContacts = self.processContacts(contacts)
//
//        completionHandler(zContacts)
//      } else {
//        completionHandler(nil)
//      }
//    }
//  }
//
//  /// Requests access to the contacts
//  private func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
//    let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
//
//    switch authorizationStatus {
//    case .authorized:
//      completionHandler(true)
//
//    case .denied, .notDetermined:
//      self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, _) -> Void in
//        if access {
//          completionHandler(access)
//        } else {
//          if authorizationStatus == CNAuthorizationStatus.denied {
//            completionHandler(false)
//          }
//        }
//      })
//
//    default:
//      completionHandler(false)
//    }
//  }
//
//  private func retrieveContacts() -> [CNContact] {
//    var results: [CNContact] = []
//
//    let keysToFetch = [
//      CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
//      CNContactEmailAddressesKey,
//      CNContactPhoneNumbersKey] as [Any]
//
//    guard let keyDescriptors = keysToFetch as? [CNKeyDescriptor] else {
//      ZLog.error("Contact key descriptor error")
//      return results
//    }
//
//    // Get all the containers
//    var allContainers: [CNContainer] = []
//    do {
//      allContainers = try contactStore.containers(matching: nil)
//    } catch {
//      print("Error fetching containers")
//    }
//
//    // Iterate all containers and append their contacts to our results array
//    for container in allContainers {
//      let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
//
//      do {
//        let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keyDescriptors )
//        results.append(contentsOf: containerResults)
//      } catch {
//        print("Error fetching results for container")
//      }
//    }
//
//    return results
//  }
//
//  private func processContacts(_ input: [CNContact]) -> [[String: Any]] {
//    var contacts = [[String: Any]]()
//    for contact in input {
//
//      var phoneNumbers = [String]()
//      var emailAddresses = [String]()
//
//      for phone in contact.phoneNumbers {
//        phoneNumbers.append(phone.value.stringValue)
//      }
//
//      for email in contact.emailAddresses {
//        emailAddresses.append(String(email.value))
//      }
//
//      let dict: [String: Any] =
//        ["first": contact.givenName,
//         "last": contact.familyName,
//         "emails": emailAddresses,
//         "phones": phoneNumbers]
//
//      contacts.append(dict)
//    }
//    return contacts
//  }
}
