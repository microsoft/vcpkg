vcpkg_buildpath_length_warning(37)
vcpkg_fail_port_install(ON_TARGET "uwp")
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/avro
    REF 8111cdc35430ff68dcb644306362859de40999d9 #release-1.10.2
    SHA512 0aad5f5445cd0daf6cda2da3631bfe56c01b259a8b2ec40ff2e0a3e90df23ee1357cafcae5520811ca5d5a232bc566defb9cf7dcb8efb8f5ed4bff7d3e8b06dd
    HEAD_REF master
    PATCHES
        avro.patch          # Private vcpkg build fixes
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/lang/c"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_tools(TOOL_NAMES avroappend avrocat AUTO_CLEAN)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_copy_tools(TOOL_NAMES avropipe avromod AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/lang/c/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)