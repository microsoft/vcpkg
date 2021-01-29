set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
if("default-feature" IN_LIST FEATURES)
    message(FATAL_ERROR "the default feature was depended upon")
endif()
