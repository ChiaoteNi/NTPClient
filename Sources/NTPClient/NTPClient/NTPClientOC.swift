//
//  NTPClientOC.swift
//
//
//  Created by Chiaote Ni on 2023/11/19.
//

import Foundation

@objc(OCNTPClock)
public class NTPClockOCWrapper: NSObject {
    
    public var currentTime: Date {
        NTPClock.currentTime ?? Date()
    }
    
    private let clock = NTPClock()
    
    public override init() {
        super.init()
        
        NTPClock.start()
    }
}
