//
//  File.swift
//  
//
//  Created by Chiaote Ni on 2023/11/21.
//

import Foundation
import NTPClient

@objcMembers
public final class OCNTPClock {
    
    public var currentTime: NSDate {
        NTPClock.currentTime as NSDate
    }
    
    init() {
        NTPClock.start()
    }
}
