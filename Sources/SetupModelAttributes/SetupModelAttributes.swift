@attached(extension, names: named(setupModel))
public macro SetupModelAttributes() = #externalMacro(
    module: "SetupModelAttributesMacro",
    type: "SetupModelAttributesMacro"
)
