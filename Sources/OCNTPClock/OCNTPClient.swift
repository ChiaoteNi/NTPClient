//
//  File.swift
//  
//
//  Created by Chiaote Ni on 2023/11/21.
//

import Foundation
import NTPClient

@objc
public final class OCNTPClock: NSObject {
    
    @objc
    public var currentTime: NSDate? {
        NTPClock.currentTime as? NSDate
    }
    
    @objc 
    public override init() {
        super.init()
        NTPClock.start()
    }
}
