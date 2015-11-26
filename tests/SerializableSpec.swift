
import Quick
import Nimble
import SwiftSerializer

class OneProperty : Serializable {
    var name : String
    
    init(name:String) {
        self.name = name
    }
}

class DataProperty : Serializable {
    var Data : NSData
    
    init(Data : NSData) {
        self.Data = Data
    }
}

class Person:Serializable {
    var Name : String
    var Surname : String
    var BirthTimestamp : NSNumber
    var BirthDate : NSDate
    var HasPets : Bool
    var Animals : Array<Animal>
    
    
    init(Name:String, Surname:String, BirthTimestamp:NSNumber, BirthDate : NSDate, HasPets : Bool) {
        self.Name = Name
        self.Surname = Surname
        self.BirthTimestamp = BirthTimestamp
        self.Animals = Array<Animal>()
        self.BirthDate = BirthDate
        self.HasPets = HasPets
    }
}

class Parent : Serializable {
    var Child : Person
    
    init(child : Person) {
        self.Child = child
    }
}

class Animal:Serializable {
    var Nickname : String
    var Kind : String
    var Trick : String?
    
    init(Nickname : String, Kind : String, Trick : String?) {
        self.Nickname = Nickname
        self.Kind = Kind
        self.Trick = Trick
    }
}

class Stock:Serializable {
    var Price : Int8
    var PE : Int16
    var Volume : Int32
    var MarketCap : Int64
    
    init(Price : Int8, PE : Int16, Volume : Int32, MarketCap : Int64) {
        self.Price = Price
        self.PE = PE
        self.Volume = Volume
        self.MarketCap = MarketCap
    }
}

class UnsignedStock:Serializable {
    var Price : UInt8
    var PE : UInt16
    var Volume : UInt32
    var MarketCap : UInt64
    
    init(Price : UInt8, PE : UInt16, Volume : UInt32, MarketCap : UInt64) {
        self.Price = Price
        self.PE = PE
        self.Volume = Volume
        self.MarketCap = MarketCap
    }
}

class SerializableSpec: QuickSpec {
    override func spec() {
        describe("OneProperty") {
            var one : OneProperty!
            
            beforeEach {
                one = OneProperty(name: "ABC")
            }
            
            it("should be serialized") {
                let expected = "{\"name\":\"ABC\"}"
                let json = one.toJsonString()
                expect(json).to(equal(expected))
            }
            
            context("pretty JSON print is enabled") {
                it("should be serialized") {
                    let expected = "{\n  \"name\" : \"ABC\"\n}"
                    let json = one.toJsonString(true)
                    expect(json).to(equal(expected))
                }
            }
        }
        
        describe("DataProperty") {
            var data : DataProperty!
            
            beforeEach {
                data = DataProperty(Data: NSData(bytes: [0xFF, 0xD9] as [UInt8], length: 2))
            }
            
            it("should be serialized") {
                let expected = "{\"Data\":\"\\/9k=\"}"
                let json = data.toJsonString()
                expect(json).to(equal(expected))
            }
            
        }
            
        describe("Person") {
            var john : Person!
            
            beforeEach {
                john = Person(Name: "John", Surname: "Doe", BirthTimestamp: 51246360, BirthDate: NSDate(timeIntervalSince1970: 10), HasPets: true)
            }
            
            it("should be serialized") {
                let expected = "{\"Animals\":[],\"BirthDate\":10,\"BirthTimestamp\":51246360,\"HasPets\":true,\"Name\":\"John\",\"Surname\":\"Doe\"}";
                expect(john.toJsonString()).to(equal(expected))
            }
        }
        
        describe("object class Person with objects in array") {
            var john : Person!
            
            beforeEach {
                john = Person(Name: "John", Surname: "Doe", BirthTimestamp: 51246360, BirthDate: NSDate(timeIntervalSince1970: 10), HasPets: true)
                john.Animals.append(Animal(Nickname: "Fluffy", Kind: "Dog", Trick: "Rollover"))
                john.Animals.append(Animal(Nickname: "Purry", Kind: "Cat", Trick: nil))
            }
            
            it("should be serialized") {
                let expected = "{\"Animals\":[{\"Kind\":\"Dog\",\"Nickname\":\"Fluffy\",\"Trick\":\"Rollover\"},{\"Kind\":\"Cat\",\"Nickname\":\"Purry\"}],\"BirthDate\":10,\"BirthTimestamp\":51246360,\"HasPets\":true,\"Name\":\"John\",\"Surname\":\"Doe\"}";
                expect(john.toJsonString()).to(equal(expected))
            }
        }
        
        describe("Array of animals") {
            var animals : [Animal]!
            
            beforeEach {
                animals = [Animal]()
                animals.append(Animal(Nickname: "Fluffy", Kind: "Dog", Trick: "Rollover"))
                animals.append(Animal(Nickname: "Purry", Kind: "Cat", Trick: nil))
            }
            
            it("should be serialized") {
                let expected = "[{\"Kind\":\"Dog\",\"Nickname\":\"Fluffy\",\"Trick\":\"Rollover\"},{\"Kind\":\"Cat\",\"Nickname\":\"Purry\"}]";
                expect(animals.toJsonString()).to(equal(expected))
            }
        }
        
        describe("Nested serializable") {
            var parent : Parent!
            
            beforeEach {
                parent = Parent(child: Person(Name: "John", Surname: "Doe", BirthTimestamp: 51246360, BirthDate: NSDate(timeIntervalSince1970: 10), HasPets: true))
            }
            
            it("should be serialized") {
                let expected = "{\"Child\":{\"Animals\":[],\"BirthDate\":10,\"BirthTimestamp\":51246360,\"HasPets\":true,\"Name\":\"John\",\"Surname\":\"Doe\"}}";
                expect(parent.toJsonString()).to(equal(expected))
            }
        }
        
        describe("Stock") {
            var stock : Stock!
            
            beforeEach {
                stock = Stock(Price: 15, PE: 55, Volume: 100000, MarketCap: 1000000)
            }
            
            it("should serialize signed integer types") {
                let expected = "{\"MarketCap\":1000000,\"PE\":55,\"Price\":15,\"Volume\":100000}";
                expect(stock.toJsonString()).to(equal(expected))
            }
        }
        
        describe("Unsigned Stock") {
            var stock : UnsignedStock!
            
            beforeEach {
                stock = UnsignedStock(Price: 15, PE: 55, Volume: 100000, MarketCap: 1000000)
            }
            
            it("should serialize unsigned integer types") {
                let expected = "{\"MarketCap\":1000000,\"PE\":55,\"Price\":15,\"Volume\":100000}";
                expect(stock.toJsonString()).to(equal(expected))
            }
        }
    }
}