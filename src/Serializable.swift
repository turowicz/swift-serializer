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
    
    /**
        Converts the class to a dictionary.
    
        :returns: The class as an NSDictionary.
    */
    public func toDictionary() -> NSDictionary {
        let propertiesDictionary = NSMutableDictionary()
        let mirror = reflect(self)
        
        for i in 1..<mirror.count {
            let (propName, childMirror) = mirror[i]
            
            if let propValue: AnyObject = self.unwrap(childMirror.value) as? AnyObject {
                if let serializablePropValue = propValue as? Serializable {
                    propertiesDictionary.setValue(serializablePropValue.toDictionary(), forKey: propName)
                } else if let arrayPropValue = propValue as? [Serializable] {
                    var subArray = [NSDictionary]()
                    for item in arrayPropValue {
                        subArray.append(item.toDictionary())
                    }
                    
                    propertiesDictionary.setValue(subArray, forKey: propName)
                } else if propValue is Int || propValue is Double || propValue is Float {
                    propertiesDictionary.setValue(propValue, forKey: propName)
                } else if let dataPropValue = propValue as? NSData {
                    propertiesDictionary.setValue(dataPropValue.base64EncodedStringWithOptions(.Encoding64CharacterLineLength), forKey: propName)
                } else if let boolPropValue = propValue as? Bool {
                    propertiesDictionary.setValue(boolPropValue, forKey: propName)
                } else {
                    propertiesDictionary.setValue(propValue, forKey: propName)
                }
            }
        }
        
        return propertiesDictionary
    }
    
    /**
        Converts the class to JSON.
    
        :returns: The class as JSON, wrapped in NSData.
    */
    public func toJson() -> NSData {
        let dictionary = self.toDictionary()
        
        var err: NSError?
        
        if let json = NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted, error: &err) {
            return json
        } else {
            let error = err?.description ?? "nil"
            print("ERROR: Unable to serialize json, error: \(error)")
            NSNotificationCenter.defaultCenter().postNotificationName("CrashlyticsLogNotification", object: self, userInfo: ["string": "unable to serialize json, error: \(error)"])
            abort()
        }
    }
    
    /**
        Converts the class to a JSON string.
    
        :returns: The class as a JSON string.
    */
    public func toJsonString() -> String! {
        return NSString(data: self.toJson(), encoding: NSUTF8StringEncoding) as String!
    }
}

extension Serializable {
    
    /**
        Unwraps 'any' object. See http://stackoverflow.com/questions/27989094/how-to-unwrap-an-optional-value-from-any-type
    
        :returns: The unwrapped object.
    */
    private func unwrap(any: Any) -> Any? {
        let mi = reflect(any)
        
        if mi.disposition != .Optional {
            return any
        }
        
        if mi.count == 0 {
            return nil
        }
        
        let (_, some) = mi[0]
        
        return some.value
    }
}
