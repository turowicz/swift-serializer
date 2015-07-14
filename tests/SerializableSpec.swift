
import Quick
import Nimble

class OneProperty : Serializable {
    var name : String
    
    init(name:String) {
        self.name = name
    }
}

class Person:Serializable {
    var Name : String
    var Surname : String
    var BirthTimestamp : NSNumber
    var Animals : Array<Animal>
    
    
    init(Name:String, Surname:String, BirthTimestamp:NSNumber) {
        self.Name = Name
        self.Surname = Surname
        self.BirthTimestamp = BirthTimestamp
        self.Animals = Array<Animal>()
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
            
        describe("Person") {
            var john : Person!
            
            beforeEach {
                john = Person(Name: "John", Surname: "Doe", BirthTimestamp: 51246360)
            }
            
            it("should be serialized") {
                let expected = "{\"BirthTimestamp\":51246360,\"Surname\":\"Doe\",\"Animals\":[],\"Name\":\"John\"}";
                expect(john.toJsonString()).to(equal(expected))
            }
        }
        
        describe("object class Person with objects in array") {
            var john : Person!
            
            beforeEach {
                john = Person(Name: "John", Surname: "Doe", BirthTimestamp: 51246360)
                john.Animals.append(Animal(Nickname: "Fluffy", Kind: "Dog", Trick: "Rollover"))
                john.Animals.append(Animal(Nickname: "Purry", Kind: "Cat", Trick: nil))
            }
            
            it("should be serialized") {
                let expected = "{\"BirthTimestamp\":51246360,\"Surname\":\"Doe\",\"Animals\":[{\"Trick\":\"Rollover\",\"Nickname\":\"Fluffy\",\"Kind\":\"Dog\"},{\"Nickname\":\"Purry\",\"Kind\":\"Cat\"}],\"Name\":\"John\"}";
                expect(john.toJsonString()).to(equal(expected))
            }
        }
    }
}