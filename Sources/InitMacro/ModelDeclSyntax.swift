import SwiftSyntax

protocol ModelDeclSyntax {
    var memberBlock: MemberBlockSyntax { get }
}

extension StructDeclSyntax: ModelDeclSyntax {}
extension ClassDeclSyntax: ModelDeclSyntax {}
