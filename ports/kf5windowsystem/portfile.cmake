vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kwindowsystem
    REF v5.89.0
    SHA512 8cdb177b5dff487c0039f6243a8652e8e0aaae5cd55f299f8ad4cd2c66651fc0be36328998807398b53803989881b511f0ee472359c6129ff809e9b50283b66a
)

if (VCPKG_TARGET_IS_LINUX)
    message(WARNING "${PORT} currently requires the following libraries from the system package manager:\n    libxcb-res0-dev\n\nThese can be installed on Ubuntu systems via apt-get install libxcb-res0-dev")
endif()

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_PLUGINDIR=plugins
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5WindowSystem CONFIG_PATH lib/cmake/KF5WindowSystem)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/KF5/KWindowSystem/config-kwindowsystem.h" "${CURRENT_PACKAGES_DIR}/" "")

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
