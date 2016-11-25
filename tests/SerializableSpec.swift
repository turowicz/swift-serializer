import Quick
import Nimble
import SwiftSerializer

class OneProperty: Serializable {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

class DataProperty: Serializable {
    var data: NSData
    
    init(data: NSData) {
        self.data = data
    }
}

class Person: Serializable {
    var name: String
    var surname: String
    var birthTimestamp: NSNumber
    var birthDate: NSDate
    var hasPets: Bool
    var animals: Array<Animal>
    
    
    init(name: String, surname: String, birthTimestamp: NSNumber, birthDate: NSDate, hasPets: Bool) {
        self.name = name
        self.surname = surname
        self.birthTimestamp = birthTimestamp
        self.animals = Array<Animal>()
        self.birthDate = birthDate
        self.hasPets = hasPets
    }
}

class Parent: Serializable {
    var child: Person
    
    init(child: Person) {
        self.child = child
    }
}

class Animal: Serializable {
    var nickname: String
    var kind: String
    var trick: String?
    
    init(nickname: String, kind: String, trick: String?) {
        self.nickname = nickname
        self.kind = kind
        self.trick = trick
    }
}

class Stock: Serializable {
    var price: Int8
    var pe: Int16
    var volume: Int32
    var marketCap: Int64
    
    init(price: Int8, pe: Int16, volume: Int32, marketCap: Int64) {
        self.price = price
        self.pe = pe
        self.volume = volume
        self.marketCap = marketCap
    }
}

class UnsignedStock: Serializable {
    var price: UInt8
    var pe: UInt16
    var volume: UInt32
    var marketCap: UInt64
    
    init(price: UInt8, pe: UInt16, volume: UInt32, marketCap: UInt64) {
        self.price = price
        self.pe = pe
        self.volume = volume
        self.marketCap = marketCap
    }
}

enum HeroType: String {
    case first, second
}

class Hero: Serializable {
    var type: HeroType
    
    init(type: HeroType) {
        self.type = type
    }
}

class SerializableSpec: QuickSpec {
    let john = Person(name: "John", surname: "Doe", birthTimestamp: 51246360, birthDate: NSDate(timeIntervalSince1970: 10), hasPets: true)

    override func spec() {
        describe("Person") {
            beforeEach {
                self.john.animals = [Animal]()
            }
            
            it("should be serialized") {
                let expected = "{\"animals\":[],\"birthDate\":10,\"birthTimestamp\":51246360,\"hasPets\":true,\"name\":\"John\",\"surname\":\"Doe\"}"
                expect(self.john.toJsonString()).to(equal(expected))
            }

            describe("object class Person with objects in array") {
                it("should be serialized") {
                    self.john.animals.append(Animal(nickname: "Fluffy", kind: "Dog", trick: "Rollover"))
                    self.john.animals.append(Animal(nickname: "Purry", kind: "Cat", trick: nil))
                    
                    let johnString = "\"birthDate\":10,\"birthTimestamp\":51246360,\"hasPets\":true,\"name\":\"John\",\"surname\":\"Doe\""
                    let fluffyString = "{\"kind\":\"Dog\",\"nickname\":\"Fluffy\",\"trick\":\"Rollover\"}"
                    let purryString = "{\"kind\":\"Cat\",\"nickname\":\"Purry\",\"trick\":null}"
                    let expected = "{\"animals\":[\(fluffyString),\(purryString)],\(johnString)}"
                    expect(self.john.toJsonString()).to(equal(expected))
                }
            }
            
            describe("Nested serializable") {
                let parent = Parent(child: self.john)
                
                it("should be serialized") {
                    let johnString = "\"birthDate\":10,\"birthTimestamp\":51246360,\"hasPets\":true,\"name\":\"John\",\"surname\":\"Doe\""
                    let expected = "{\"child\":{\"animals\":[],\(johnString)}}"
                    expect(parent.toJsonString()).to(equal(expected))
                }
            }
        }
    }
}

class SerializableIntegerSpec: QuickSpec {
    override func spec() {
        describe("Stock") {
            let stock = Stock(price: 15, pe: 55, volume: 100000, marketCap: 1000000)
            
            it("should serialize signed integer types") {
                let expected = "{\"marketCap\":1000000,\"pe\":55,\"price\":15,\"volume\":100000}"
                expect(stock.toJsonString()).to(equal(expected))
            }
        }
        
        describe("Unsigned Stock") {
            let stock = UnsignedStock(price: 15, pe: 55, volume: 100000, marketCap: 1000000)
            
            it("should serialize unsigned integer types") {
                let expected = "{\"marketCap\":1000000,\"pe\":55,\"price\":15,\"volume\":100000}"
                expect(stock.toJsonString()).to(equal(expected))
            }
        }
    }
}

class SerializableDataSpec: QuickSpec {
    override func spec() {
        describe("DataProperty") {
            let data = DataProperty(data: NSData(bytes: [0xFF, 0xD9] as [UInt8], length: 2))
            
            it("should be serialized") {
                expect(data.toJsonString()).to(equal("{\"data\":\"\\/9k=\"}"))
            }
        }
    }
}

class SerializableArraySpec: QuickSpec {
    override func spec() {
        describe("Array of animals") {
            var animals = [Animal]()
            
            beforeEach {
                animals.append(Animal(nickname: "Fluffy", kind: "Dog", trick: "Rollover"))
                animals.append(Animal(nickname: "Purry", kind: "Cat", trick: nil))
            }
            
            it("should be serialized") {
                let expected = "[{\"kind\":\"Dog\",\"nickname\":\"Fluffy\",\"trick\":\"Rollover\"},{\"kind\":\"Cat\",\"nickname\":\"Purry\",\"trick\":null}]"
                expect(animals.toJsonString()).to(equal(expected))
            }
        }
    }
}


class SerializableEnumSpec: QuickSpec {
    override func spec() {
        describe("Enum") {
            let hero = Hero(type: .first)
            
            it("should be serialized") {
                let expected = "{\"type\":\"first\"}"
                expect(hero.toJsonString()).to(equal(expected))
            }
        }
    }
}
