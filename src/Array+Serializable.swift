/*

Serializes an array to JSON making use of the Serializable class

*/

import Foundation

extension Array where Element: Serializable {
    
    public func toNSDictionaryArray() -> [NSDictionary] {
        var subArray = [NSDictionary]()
        for item in self {
            subArray.append(item.toDictionary())
        }
        return subArray
    }
    
    /**
    Converts the array to JSON.
    
    :returns: The array as JSON, wrapped in NSData.
    */
    public func toJson(prettyPrinted: Bool = false) -> NSData? {
        let subArray = self.toNSDictionaryArray()
        
        if NSJSONSerialization.isValidJSONObject(subArray) {
            do {
                let json = try NSJSONSerialization.dataWithJSONObject(subArray, options: (prettyPrinted ? .PrettyPrinted: NSJSONWritingOptions()))
                return json
            } catch let error as NSError {
                print("ERROR: Unable to serialize json, error: \(error)")
            }
        }
        
        return nil
    }
    
    /**
    Converts the array to a JSON string.
    
    :returns: The array as a JSON string.
    */
    public func toJsonString(prettyPrinted: Bool = false) -> String? {
        if let jsonData = toJson(prettyPrinted) {
            return NSString(data: jsonData, encoding: NSUTF8StringEncoding) as String?
        }
        
        return nil
    }
}
