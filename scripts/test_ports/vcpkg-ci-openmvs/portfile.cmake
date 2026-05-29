set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/openMVS
    REF "v2.3.0"
    SHA512 c8af808393836d0ac508cf4f1d123cf297b451927fe4ad95dd27e041099818cd6d077f95b03e34cd9fe92bf0277cce8e9386311531093d6469b8e07f08b15aba
    HEAD_REF master
    PATCHES
        standalone.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/libs")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/apps/Tests"
)
vcpkg_cmake_build()
