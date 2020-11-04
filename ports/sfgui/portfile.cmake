vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TankOs/SFGUI
    REF 0.4.0
    SHA512 15456c6080b7095bcdcec08489b2b91b5cfc36cdf3c0b645b305072e7e835837eb4f95b59371ff176630b2b7ae51da475d8ea0bde5ff7fc0ba74c463bf5f54cf
    HEAD_REF master
    PATCHES
        "001-fix-corefoundation-link.patch"
)

file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindSFML.cmake)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SFGUI_BUILD_SHARED_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSFGUI_BUILD_DOC=OFF
        -DSFGUI_BUILD_EXAMPLES=OFF
        -DSFGUI_BUILD_SHARED_LIBS=${SFGUI_BUILD_SHARED_LIBS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
    file(GLOB_RECURSE SFGUI_DOC_RELEASE ${CURRENT_PACKAGES_DIR}/*.md)
    file(GLOB_RECURSE SFGUI_DOC_DEBUG ${CURRENT_PACKAGES_DIR}/debug/*.md)
    file(REMOVE ${SFGUI_DOC_RELEASE} ${SFGUI_DOC_DEBUG})
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/SFGUI/cmake)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/sfgui RENAME copyright)
