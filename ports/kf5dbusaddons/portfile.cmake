vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kdbusaddons
    REF v5.81.0
    SHA512 fce5b646199ee895f2c8ed17382cb4b7f0265a87558ba3b7bb094cbfa92327b8fb910e4af95f1d3793c1908151eefd59783b31fe43c0743ea872632bb78d98f0
    HEAD_REF master
)

vcpkg_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_HTML_DOCS=OFF
        -DBUILD_MAN_DOCS=OFF
        -DBUILD_QTHELP_DOCS=OFF
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