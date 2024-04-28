import XCTest
import MacroTesting
import CoreDataAttributesConvenienceSetupMacro

final class SetupCoreDataAttributesTests: XCTestCase {
    
    func testSetupCoreDataAttributes() {
        assertMacro(["SetupCoreDataAttributes": CoreDataAttributesConvenienceSetupMacro.self]) {
            """
            @SetupCoreDataAttributes
            public class MyModel: NSManagedObject {

                @nonobjc class func fetchRequest() -> NSFetchRequest<MyModel> {
                    return NSFetchRequest<MyModel>(entityName: "MyModel")
                }

                @NSManaged var a: Double
                @NSManaged var b: Date
                @NSManaged var c: Double
                @NSManaged var d: Double
            }

            """
        } expansion: {
            """
            public class MyModel: NSManagedObject {

                @nonobjc class func fetchRequest() -> NSFetchRequest<MyModel> {
                    return NSFetchRequest<MyModel>(entityName: "MyModel")
                }

                @NSManaged var a: Double
                @NSManaged var b: Date
                @NSManaged var c: Double
                @NSManaged var d: Double
            }

            extension MyModel {
             public func setupModel(a: Double, b: Date, c: Double, d: Double) {
             self.a = a
             self.b = b
             self.c = c
             self.d = d
             }
            }
            """
        }
    }
}
