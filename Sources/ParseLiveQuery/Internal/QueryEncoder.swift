/**
 * Copyright (c) 2016-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import Foundation
import Parse

/**
 NOTE: This is super hacky, and we need a better answer for this.
 */
internal extension Dictionary where Key: StringLiteralConvertible, Value: AnyObject {
    internal init(query: PFQuery) {
        self.init()

        let queryState = query.valueForKey("state")
        if let className = queryState?.valueForKey("parseClassName") {
            self["className"] = className as? Value
        }
        let objectDictionary = { (object:PFObject)->[String:String] in
            return ["__type":"Pointer","className": object.parseClassName,"objectId": object.objectId!] }
        var valueBlock:((AnyObject)->AnyObject?)!
        valueBlock = {(value:AnyObject)->AnyObject? in
            if let value = value as? PFObject {
                return objectDictionary(value) }
            if let value = value as? [String:AnyObject] {
                guard let (key,value) = value.first else {
                    fatalError("Value is bad formatted.")
                    return nil}
                guard let optional = valueBlock(value) else {
                    fatalError("Value is bad formatted.")
                    return nil}
                return [key: optional] }
            return value }
        
        if let rawConditions: [String:AnyObject] = queryState?.valueForKey("conditions") as? [String:AnyObject] {
            var formattedConditions = [String: AnyObject]()
            let keys = rawConditions.keys
            for (key,value) in rawConditions {
                formattedConditions[key] = valueBlock(value)
            }
            self["where"] = formattedConditions as? Value
        }
    }
}
