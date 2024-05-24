import XCTest
import MacroTesting
import SetupModelAttributesMacro

final class SetupModelAttributesTests: XCTestCase {
    
    func testSetupModelAttributes() {
        assertMacro(["SetupModelAttributes": SetupModelAttributesMacro.self]) {
            """
            @SetupModelAttributes
            public class MyModel {
                var a: Double
                var b: Date
                var c: Double
                var d: Double
            }

            """
        } expansion: {
            """
            public class MyModel {
                var a: Double
                var b: Date
                var c: Double
                var d: Double
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
