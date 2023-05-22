set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(READ "${CMAKE_CURRENT_LIST_DIR}/usage" usage)
message(WARNING "find_package(unofficial-recast) is deprecated.\n${usage}")