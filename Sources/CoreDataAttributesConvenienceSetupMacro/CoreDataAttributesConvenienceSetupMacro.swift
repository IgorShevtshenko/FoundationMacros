import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

internal enum CoreDataAttributesConvenienceSetupError: CustomStringConvertible, Error {

    case onlyApplicableToClasses
    case invalidSyntax

    var description: String {
        switch self {
        case .onlyApplicableToClasses:
            "@CoreDataAttributesConvenienceSetup can only be applied to class"
        case .invalidSyntax:
            "Invalid syntax"
        }
    }
}

public struct CoreDataAttributesConvenienceSetupMacro: ExtensionMacro {
        
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let structDecl = declaration as? ClassDeclSyntax else {
            throw CoreDataAttributesConvenienceSetupError.onlyApplicableToClasses
        }
        let members = structDecl.memberBlock.members
        let variables = members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { $0.isVar }
        let variablesName = variables.compactMap { $0.bindings.first?.pattern }
        let variablesType = variables.compactMap { $0.bindings.first?.typeAnnotation?.type }
        
        let setupFunction = try FunctionDeclSyntax(
            buildFunctionHeader(variablesName: variablesName, variablesType: variablesType),
            bodyBuilder: { buildFunctionBody(variablesName: variablesName) }
        )
        
        let extensionSyntax = try ExtensionDeclSyntax("""
        extension \(type.trimmed) {
         \(setupFunction)
        }
        """
        )
        return [extensionSyntax]
    }
    
    private static func buildFunctionHeader(
        variablesName: [PatternSyntax],
        variablesType: [TypeSyntax]
    ) throws -> SyntaxNodeString {
        let parameters = zip(variablesName, variablesType)
            .map { name, type in
                "\(name): \(type)"
            }
            .joined(separator: ", ")
        let header = ["public func setupModel(", parameters, ")"].joined()

        return SyntaxNodeString(stringLiteral: header)
    }

    @CodeBlockItemListBuilder
    private static func buildFunctionBody(variablesName: [PatternSyntax]) -> CodeBlockItemListSyntax {
        for name in variablesName {
            ExprSyntax("\nself.\(name) = \(name)")
        }
    }
}

private extension VariableDeclSyntax {

    var isVar: Bool {
        bindingSpecifier.tokenKind == .keyword(.var)
    }
}

@main
internal struct CoreDataAttributesConvenienceSetup: CompilerPlugin {

    let providingMacros: [Macro.Type] = [
        CoreDataAttributesConvenienceSetupMacro.self,
    ]
}
