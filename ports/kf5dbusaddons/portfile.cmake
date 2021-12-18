vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kdbusaddons
    REF v5.87.0
    SHA512 d37a0e28d6a78bbde3fbf0cb4669711edebc27b295beb7a29f60751cbd21448c3ea6f82e487b889e466908f2217d1477552cd4ae3399b761700f0789edfc02d4
    HEAD_REF master
    PATCHES
        x11_private_dependency.diff
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5DBusAddons CONFIG_PATH lib/cmake/KF5DBusAddons)

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
elseif(VCPKG_TARGET_IS_WINDOWS)
    # kquitapp5 is a non-dev tool allowing to quit an arbitrary, dbus-compatible app. No need to keep it.
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/kquitapp5${VCPKG_HOST_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/debug/bin/kquitapp5${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
