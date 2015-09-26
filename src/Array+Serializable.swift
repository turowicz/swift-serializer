/*

Serializes an array to JSON making use of the Serializable class

*/

import Foundation

extension Array where Element: Serializable {
    /**
    Converts the array to JSON.
    
    :returns: The array as JSON, wrapped in NSData.
    */
    public func toJson(prettyPrinted : Bool = false) -> NSData? {
        var subArray = [NSDictionary]()
        for item in self {
            subArray.append(item.toDictionary())
        }
        
        if NSJSONSerialization.isValidJSONObject(subArray) {
            do {
                let json = try NSJSONSerialization.dataWithJSONObject(subArray, options: (prettyPrinted ? .PrettyPrinted : NSJSONWritingOptions()))
                return json
            } catch {
                //currently swift will not catch NSInvalidArgumentException exception
                print("ERROR: Unable to serialize json, error: \(error)")
                NSNotificationCenter.defaultCenter().postNotificationName("CrashlyticsLogNotification", object: self, userInfo: ["string": "unable to serialize json, error: \(error)"])
            }
        }
        
        return nil
    }
    
    /**
    Converts the array to a JSON string.
    
    :returns: The array as a JSON string.
    */
    public func toJsonString(prettyPrinted : Bool = false) -> String? {
        if let jsonData = toJson(prettyPrinted) {
            return NSString(data: jsonData, encoding: NSUTF8StringEncoding) as String?
        }
        
        return nil
    }
}