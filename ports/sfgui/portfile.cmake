vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TankOs/SFGUI
    REF 1.0.0
    SHA512 cc543cd44cf7d922d086748eea57d75069682649aa5f788bfc6ec3baa7bf7f9a010b4314d1a1875648cfaabf8d9efef130843ac1848d1112b5d53fd508768e41
    HEAD_REF master
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
