//
//  Notepad-macOS.swift
//  Notepad
//
//  Created by Christian Tietze on 2017-07-21.
//  Copyright © 2017 Rudd Fawcett. All rights reserved.
//

#if os(macOS)
import AppKit

public class Notepad: NSTextView {

    var storage: Storage = Storage()
}
#endif
