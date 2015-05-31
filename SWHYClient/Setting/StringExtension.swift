//
//  StringExtension.swift
//  SWHYClient
//
//  Created by sunny on 5/13/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import Foundation

extension String {
    static func className(aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).componentsSeparatedByString(".").last!
    }
}
