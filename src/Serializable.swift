/*

Converts A class to a dictionary, used for serializing dictionaries to JSON

Supported objects:
- Serializable derived classes (sub classes)
- Arrays of Serializable
- NSData
- String, Numeric, and all other NSJSONSerialization supported objects

*/

import Foundation

public class Serializable: NSObject {
    private class SortedDictionary: NSMutableDictionary {
        var dictionary = [String: AnyObject]()
        
        override var count: Int {
            return dictionary.count
        }
        
        override func keyEnumerator() -> NSEnumerator {
            let sortedKeys: NSArray = dictionary.keys.sort()
            return sortedKeys.objectEnumerator()
        }
        
        override func setValue(value: AnyObject?, forKey key: String) {
            dictionary[key] = value
        }
        
        override func objectForKey(aKey: AnyObject) -> AnyObject? {
            if let key = aKey as? String {
                return dictionary[key]
            }
            
            return nil
        }
    }
    
    
    public func formatKey(key: String) -> String {
        return key
    }
    
    public func formatValue(value: AnyObject?, forKey: String) -> AnyObject? {
        return value
    }
    
    func setValue(dictionary: NSDictionary, value: AnyObject?, forKey: String) {
        dictionary.setValue(formatValue(value, forKey: forKey), forKey: formatKey(forKey))
    }
    
    /**
    Converts the class to a dictionary.

    - returns: The class as an NSDictionary.
    */
    public func toDictionary() -> NSDictionary {
        let propertiesDictionary = SortedDictionary()
        let mirror = Mirror(reflecting: self)
        for (propName, propValue) in mirror.children {
            if let propValue: AnyObject = self.unwrap(propValue) as? AnyObject, propName = propName {
                if let serializablePropValue = propValue as? Serializable {
                    setValue(propertiesDictionary, value: serializablePropValue.toDictionary(), forKey: propName)
                } else if let arrayPropValue = propValue as? [Serializable] {
                    let subArray = arrayPropValue.toNSDictionaryArray()
                    setValue(propertiesDictionary, value: subArray, forKey: propName)
                } else if propValue is Int || propValue is Double || propValue is Float || propValue is Bool {
                    setValue(propertiesDictionary, value: propValue, forKey: propName)
                } else if let dataPropValue = propValue as? NSData {
                    setValue(propertiesDictionary,
                        value: dataPropValue.base64EncodedStringWithOptions(.Encoding64CharacterLineLength), forKey: propName)
                } else if let datePropValue = propValue as? NSDate {
                    setValue(propertiesDictionary, value: datePropValue.timeIntervalSince1970, forKey: propName)
                } else {
                    setValue(propertiesDictionary, value: propValue, forKey: propName)
                }
            } else if let propValue: Int8 = propValue as? Int8 {
                setValue(propertiesDictionary, value: NSNumber(char: propValue), forKey: propName!)
            } else if let propValue: Int16 = propValue as? Int16 {
                setValue(propertiesDictionary, value: NSNumber(short: propValue), forKey: propName!)
            } else if let propValue: Int32 = propValue as? Int32 {
                setValue(propertiesDictionary, value: NSNumber(int: propValue), forKey: propName!)
            } else if let propValue: Int64 = propValue as? Int64 {
                setValue(propertiesDictionary, value: NSNumber(longLong: propValue), forKey: propName!)
            } else if let propValue: UInt8 = propValue as? UInt8 {
                setValue(propertiesDictionary, value: NSNumber(unsignedChar: propValue), forKey: propName!)
            } else if let propValue: UInt16 = propValue as? UInt16 {
                setValue(propertiesDictionary, value: NSNumber(unsignedShort: propValue), forKey: propName!)
            } else if let propValue: UInt32 = propValue as? UInt32 {
                setValue(propertiesDictionary, value: NSNumber(unsignedInt: propValue), forKey: propName!)
            } else if let propValue: UInt64 = propValue as? UInt64 {
                setValue(propertiesDictionary, value: NSNumber(unsignedLongLong: propValue), forKey: propName!)
            } else if isEnum(propValue) {
                setValue(propertiesDictionary, value: "\(propValue)", forKey: propName!)
            }
        }

        return propertiesDictionary
    }

    /**
    Converts the class to JSON.

    - returns: The class as JSON, wrapped in NSData.
    */
    public func toJson(prettyPrinted: Bool = false) -> NSData? {
        let dictionary = self.toDictionary()

        if NSJSONSerialization.isValidJSONObject(dictionary) {
            do {
                let json = try NSJSONSerialization.dataWithJSONObject(dictionary, options: (prettyPrinted ? .PrettyPrinted: NSJSONWritingOptions()))
                return json
            } catch let error as NSError {
                print("ERROR: Unable to serialize json, error: \(error)")
            }
        }

        return nil
    }

    /**
    Converts the class to a JSON string.

    - returns: The class as a JSON string.
    */
    public func toJsonString(prettyPrinted: Bool = false) -> String? {
        if let jsonData = self.toJson(prettyPrinted) {
            return NSString(data: jsonData, encoding: NSUTF8StringEncoding) as String?
        }

        return nil
    }
    
    
    /**
    Unwraps 'any' object. See http://stackoverflow.com/questions/27989094/how-to-unwrap-an-optional-value-from-any-type

    - returns: The unwrapped object.
    */
    func unwrap(any: Any) -> Any? {
        let mi = Mirror(reflecting: any)
        if mi.displayStyle != .Optional {
            return any
        }
        
        if mi.children.count == 0 { return nil }
        let (_, some) = mi.children.first!
        return some
    }
    
    func isEnum(any: Any) -> Bool {
        return Mirror(reflecting: any).displayStyle == .Enum
    }
}
