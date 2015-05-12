/*

    Converts A class to a dictionary, used for serializing dictionaries to JSON

    Supported objects:
    - Serializable derived classes (sub classes)
    - Arrays of Serializable
    - NSData
    - String, Numeric, and all other NSJSONSerialization supported objects

*/

import Foundation

public class Serializable : NSObject{
    // http://stackoverflow.com/questions/27989094/how-to-unwrap-an-optional-value-from-any-type
    func unwrap(any:Any) -> Any? {
        let mi = reflect(any)
        if mi.disposition != .Optional {
            return any
        }

        // Optional.None
        if mi.count == 0 {
            return nil
        }

        let (_,some) = mi[0]
        return some.value
    }

    public func toDictionary() -> NSDictionary {
        var propertiesDictionary = NSMutableDictionary()
        var mirror = reflect(self);
        for i in 1..<(mirror.count) {
            let (propName, childMirror) = mirror[i]
            if let propValue:AnyObject = unwrap(childMirror.value) as? AnyObject {
                if let serializeablePropValue = propValue as? Serializable {
                    propertiesDictionary.setValue(serializeablePropValue.toDictionary(), forKey: propName)
                } else if let arrayPropValue = propValue as? Array<Serializable> {
                    var subArray = Array<NSDictionary>()
                    for item in arrayPropValue {
                        subArray.append(item.toDictionary())
                    }
                    propertiesDictionary.setValue(subArray, forKey: propName)
                } else if propValue is Int || propValue is Double || propValue is Float {
                    propertiesDictionary.setValue(propValue, forKey: propName)
                } else if let dataPropValue = propValue as? NSData {
                    propertiesDictionary.setValue(dataPropValue.base64EncodedStringWithOptions(nil), forKey: propName)
                } else if let boolPropValue = propValue as? Bool {
                    propertiesDictionary.setValue(boolPropValue.boolValue, forKey: propName)
                } else {
                    propertiesDictionary.setValue(propValue, forKey: propName)
                }
            }
        }

        return propertiesDictionary
    }
    
    public func toJson() -> NSData {
        var dictionary = self.toDictionary()
        
        var err: NSError?
        if let json = NSJSONSerialization.dataWithJSONObject(dictionary, options:NSJSONWritingOptions(0), error: &err) {
            return json
        }
        else {
            let error = err?.description ?? "nil"
            NSLog("ERROR: Unable to serialize json, error: %@", error)
            NSNotificationCenter.defaultCenter().postNotificationName("CrashlyticsLogNotification", object: self, userInfo: ["string": "unable to serialize json, error: \(error)"])
            abort()
        }
    }
    
    public func toJsonString() -> NSString! {
        return NSString(data: self.toJson(), encoding: NSUTF8StringEncoding)
    }

}
