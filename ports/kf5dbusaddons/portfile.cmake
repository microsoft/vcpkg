vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kdbusaddons
    REF v5.84.0
    SHA512 cef640da611ead5fc002f365a9918db1bebe494d7dc456dca8a239873b7f53c1aee81d122cbc15d88cb1deeae1ab7db8c2a79a2847deb87f29c5f1c19a46ab46
    HEAD_REF master
)

vcpkg_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH ${SOURCE_PATH}
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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)