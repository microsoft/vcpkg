if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported by EASTL. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/eastl)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EASTL
    REF 3.12.04
    SHA512 99e8fdc5fb589410187f3538b6f491bc6f988babcb29b74be90a938ba6c94ad1b16d55ff62ddcf5ae539c67f473d43a6af581278b8b39d0d8686b0161dd0e5cf
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/eastl RENAME copyright)
file(INSTALL ${SOURCE_PATH}/3RDPARTYLICENSES.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/eastl)
