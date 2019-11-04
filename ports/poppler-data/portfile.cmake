include(vcpkg_common_functions)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO poppler/poppler-data
    REF POPPLER_DATA_0_4_9
    SHA512 2dd3a86a5c68351eea700874a6536cde9040e383e868e0d6bd3aa44afde121b851166d82f015b35fe9e794f8a80d5ddfc9f04216c0cd4cd0aa204efc9ff815d8
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/poppler ${CURRENT_PACKAGES_DIR}/share/poppler-data)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/poppler-data-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/poppler-data)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/poppler-data RENAME copyright)
file(INSTALL ${SOURCE_PATH}/COPYING.adobe DESTINATION ${CURRENT_PACKAGES_DIR}/share/poppler-data RENAME copyright.adobe)
file(INSTALL ${SOURCE_PATH}/COPYING.gpl2 DESTINATION ${CURRENT_PACKAGES_DIR}/share/poppler-data RENAME copyright.gpl2)

SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

