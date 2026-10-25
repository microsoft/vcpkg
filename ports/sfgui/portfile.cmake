vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TankOs/SFGUI
    REF 1.0.1
    SHA512 dc09f0d903c71b8a5e67204155cbd79cbb8bc9f84c52c331d7843e0641ac3c04ace176b1000e8435b5e0e978ba0d04c549665ba36189282db0a11eafc39c72e5
    HEAD_REF master
    PATCHES
        fix-cmake-version.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SFGUI_BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSFGUI_BUILD_DOC=OFF
        -DSFGUI_BUILD_EXAMPLES=OFF
        -DSFGUI_BUILD_SHARED_LIBS=${SFGUI_BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
    file(GLOB_RECURSE SFGUI_DOC_RELEASE "${CURRENT_PACKAGES_DIR}/*.md")
    file(GLOB_RECURSE SFGUI_DOC_DEBUG "${CURRENT_PACKAGES_DIR}/debug/*.md")
    file(REMOVE ${SFGUI_DOC_RELEASE} ${SFGUI_DOC_DEBUG})
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH share/SFGUI/cmake)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/SFGUI/Config.hpp" "defined( SFGUI_SYSTEM_WINDOWS ) && !defined( SFGUI_STATIC )" "0")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
