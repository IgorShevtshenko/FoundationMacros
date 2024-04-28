import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

internal enum InitError: CustomStringConvertible, Error {

    case onlyApplicableToStructAndClasses

    var description: String {
        switch self {
        case .onlyApplicableToStructAndClasses:
            "@Init can only be applied to a structure or class"
        }
    }
}

public struct InitMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration as? ModelDeclSyntax else {
            throw InitError.onlyApplicableToStructAndClasses
        }
        let members = structDecl.memberBlock.members
        let variables = members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { !$0.isComputedProperty }
        let variablesName = variables.compactMap { $0.bindings.first?.pattern }
        let variablesType = variables.compactMap { $0.bindings.first?.typeAnnotation?.type }

        let initializer = try InitializerDeclSyntax(
            buildInitHeader(variablesName: variablesName, variablesType: variablesType),
            bodyBuilder: { buildInitBody(variablesName: variablesName) }
        )

        return [DeclSyntax(initializer)]
    }
    
    
    private static func buildInitHeader(
        variablesName: [PatternSyntax],
        variablesType: [TypeSyntax]
    ) throws -> SyntaxNodeString {
        let parameters = zip(variablesName, variablesType)
            .map { name, type in
                let defaultNilValue = if type.isOptional {
                    " = nil"
                } else { "" }
                return "\(name): \(type)\(defaultNilValue)"
            }
            .joined(separator: ", ")
        let header = ["public init(", parameters, ")"].joined()

        return SyntaxNodeString(stringLiteral: header)
    }

    @CodeBlockItemListBuilder
    private static func buildInitBody(variablesName: [PatternSyntax]) -> CodeBlockItemListSyntax {
        for name in variablesName {
            ExprSyntax("self.\(name) = \(name)")
        }
    }
}

private extension TypeSyntax {

    var isOptional: Bool {
        self.as(OptionalTypeSyntax.self) != nil
    }
}

private extension VariableDeclSyntax {

    var isComputedProperty: Bool {
        guard
            bindings.count == 1,
            let binding = bindings.first?.as(PatternBindingSyntax.self)
        else { return false }

        return bindingSpecifier.tokenKind == .keyword(.var) && binding.isComputedProperty
    }
}

private extension PatternBindingSyntax {

    var isComputedProperty: Bool {
        guard let accessors = accessorBlock?.accessors else { return false }

        switch accessors {
        case .accessors(let accessors):
            let tokenKinds = accessors
                .compactMap { $0 }
                .map(\.accessorSpecifier.tokenKind)
            let propertyObservers: [TokenKind] = [.keyword(.didSet), .keyword(.willSet)]

            return !tokenKinds.allSatisfy(propertyObservers.contains)

        case .getter:
            return true
        }
    }
}

@main
internal struct Init: CompilerPlugin {

    let providingMacros: [Macro.Type] = [
        InitMacro.self,
    ]
}
