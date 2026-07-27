set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

message(WARNING
    "jwsung91-unilink has been renamed to wirestead and no longer builds "
    "anything itself. It now only depends on wirestead so that installing "
    "it does not conflict with wirestead's own files. Update your "
    "dependencies to use \"wirestead\" directly."
)
