vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/ktexteditor
    REF "v${VERSION}"
    SHA512 e860b06bf111c57d3f0c4380c87741ec8cc32e2d8dad0356520ecbd6fdfbd0ac5b323c9967a1b4a431d4186277fea1a6d335d226fb03fe2fd3f02e37b184d2ef
    HEAD_REF master
)

# A trick for `kcoreaddons_desktop_to_json` (see KF5CoreAddonsMacros.cmake) to generate katepart.desktop
# The copied *.desktop files should be removed after vcpkg_cmake_install
file(COPY "${CURRENT_INSTALLED_DIR}/share/kservicetypes5" DESTINATION "${CURRENT_PACKAGES_DIR}/share")
file(GLOB TEMP_DESKTOP_FILES_REL "${CURRENT_PACKAGES_DIR}/share/kservicetypes5/*")
if(NOT VCPKG_BUILD_TYPE)
    file(COPY "${CURRENT_INSTALLED_DIR}/share/kservicetypes5" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share")
    file(GLOB TEMP_DESKTOP_FILES_DBG "${CURRENT_PACKAGES_DIR}/debug/share/kservicetypes5/*")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DENABLE_KAUTH=OFF
        -DVCPKG_HOST_TRIPLET=${VCPKG_HOST_TRIPLET}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5TextEditor)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    ${TEMP_DESKTOP_FILES_DBG} ${TEMP_DESKTOP_FILES_REL}
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
