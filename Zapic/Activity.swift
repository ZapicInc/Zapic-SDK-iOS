//
//  Activity.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/21/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

enum ActivityType {
    case appStarted
}


class Activity{
    let type:ActivityType
    let timeStamp = Date()
    
    init(_ type:ActivityType){
        self.type = type
    }
}
