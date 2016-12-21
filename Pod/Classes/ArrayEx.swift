//
//  ArrayEx.swift
//  Ampdot
//  Adapted by Martin Jacob Rehder on 2016/04/17
//
//  Original by
//
//  Created by Takuma Yoshida on 2015/06/02.
//  Copyright (c) 2015年 yoavlt All rights reserved.
//

import Foundation

extension Array {
    func each(_ f: (Element) -> ()) {
        for item in self {
            f(item)
        }
    }
}
