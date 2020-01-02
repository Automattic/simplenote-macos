//
//  Style.swift
//  Notepad
//
//  Created by Rudd Fawcett on 10/14/16.
//  Copyright © 2016 Rudd Fawcett. All rights reserved.
//

import Foundation

struct Style {
    let regex: NSRegularExpression
    let attributes: [NSAttributedString.Key: AnyObject]

    init(element: Element, attributes: [NSAttributedString.Key: AnyObject]) {
        self.regex = element.toRegex()
        self.attributes = attributes
    }
}
