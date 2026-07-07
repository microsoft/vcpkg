vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jwsung91/unilink
    REF v${VERSION}
    SHA512 9bab9e551955caf916349c554aea91fa64c75c8928bbf89947b9e47f162698373318aff42deefdb4169f8e47d794014317c5108e7416747b38f1e60fd01a75e0
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" UNILINK_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNILINK_BUILD_SHARED=${UNILINK_BUILD_SHARED}
        -DUNILINK_BUILD_TESTS=OFF
        -DUNILINK_BUILD_EXAMPLES=OFF
        -DUNILINK_BUILD_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME unilink
    CONFIG_PATH "lib/cmake/unilink"
)

vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    foreach(_pc_file IN ITEMS
        "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/unilink.pc"
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/unilink.pc")
        if(EXISTS "${_pc_file}")
            file(READ "${_pc_file}" _unilink_pc_contents)
            string(REGEX REPLACE "([ \\t]+)-lboost_system" "\\1" _unilink_pc_contents "${_unilink_pc_contents}")
            string(REPLACE "-lboost_system" "" _unilink_pc_contents "${_unilink_pc_contents}")
            file(WRITE "${_pc_file}" "${_unilink_pc_contents}")
        endif()
    endforeach()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
