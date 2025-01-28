vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/ktexteditor
    REF v5.98.0
    SHA512 06aad3993cd2133b99ef9e8b510c8b89a844ce778a71351797122c6b05e31e6277d238a8563653a42aafe773457ec89842bbd6184277d471069969c177304696
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

# A trick for `kcoreaddons_desktop_to_json` (see KF5CoreAddonsMacros.cmake) to generate katepart.desktop
# The copied *.desktop files should be removed after vcpkg_cmake_install
if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(DATAROOT "bin/data") # maybe ADD_BIN_TO_PATH can work in this case...
    elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(DATAROOT "share")
    endif()
    if(NOT VCPKG_BUILD_TYPE)
        file(COPY "${CURRENT_INSTALLED_DIR}/${DATAROOT}/kservicetypes5" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin/data")
        file(GLOB TEMP_DESKTOP_FILES_DBG "${CURRENT_PACKAGES_DIR}/debug/${DATAROOT}/kservicetypes5/*")
    endif()
    file(COPY "${CURRENT_INSTALLED_DIR}/${DATAROOT}/kservicetypes5" DESTINATION "${CURRENT_PACKAGES_DIR}/bin/data")
    file(GLOB TEMP_DESKTOP_FILES_REL "${CURRENT_PACKAGES_DIR}/${DATAROOT}/kservicetypes5/*")
else()
    if(NOT VCPKG_BUILD_TYPE)
        file(COPY "${CURRENT_INSTALLED_DIR}/share/kservicetypes5" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share")
        file(GLOB TEMP_DESKTOP_FILES_DBG "${CURRENT_PACKAGES_DIR}/debug/share/kservicetypes5/*")
    endif()
    file(COPY "${CURRENT_INSTALLED_DIR}/share/kservicetypes5" DESTINATION "${CURRENT_PACKAGES_DIR}/share")
    file(GLOB TEMP_DESKTOP_FILES_REL "${CURRENT_PACKAGES_DIR}/share/kservicetypes5/*")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DENABLE_KAUTH=OFF
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DVCPKG_HOST_TRIPLET=${VCPKG_HOST_TRIPLET}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5TextEditor CONFIG_PATH lib/cmake/KF5TextEditor)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    ${TEMP_DESKTOP_FILES_DBG} ${TEMP_DESKTOP_FILES_REL}
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
