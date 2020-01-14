include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liteserver/binn
    REF 38019c11e582e5078436b8257887e79a33db8b28
    SHA512 82c7ef211154303ebb4cb991e620da520231edd224de674d4dabc42760fd7b8b6dd7be167d6c0b6c04146ea7e077b0bcff14312be909cb4ebb1ec786863d3fb4
    HEAD_REF master
    PATCHES
        0001_fix_uwp.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

file(INSTALL ${SOURCE_PATH}/src/binn.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/binn)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/binn)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/binn/LICENSE ${CURRENT_PACKAGES_DIR}/share/binn/copyright)
