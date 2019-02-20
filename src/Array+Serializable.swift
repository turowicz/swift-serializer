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
    public func toJson(_ prettyPrinted: Bool = false) -> Data? {
        let subArray = self.toNSDictionaryArray()
        
        if JSONSerialization.isValidJSONObject(subArray) {
            do {
                let json = try JSONSerialization.data(withJSONObject: subArray, options: (prettyPrinted ? .prettyPrinted : JSONSerialization.WritingOptions()))
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
    public func toJsonString(_ prettyPrinted : Bool = false) -> String? {
        if let jsonData = toJson(prettyPrinted) {
            return NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String?
        }
        
        return nil
    }
}
