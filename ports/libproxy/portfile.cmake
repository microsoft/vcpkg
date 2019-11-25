vcpkg_fail_port_install(ON_TARGET "UWP" ON_ARCH "arm" "arm64")

# Enable static build in UNIX
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fail_port_install(ON_LIBRARY_LINKAGE "static")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libproxy/libproxy
    REF 5924d4223e2b7238607749d977c0a878fe33cdbc #0.4.15
    SHA512 3c3be46e1ccd7e25a9b6e5fd71bfac5c1075bc9230a9a7ca94ee5e82bdbf090ab08dd53d8c6946db1353024409b234b35822d22f95a02cfb48bb54705b07d478
    HEAD_REF master
    PATCHES
        fix-tools-path.patch
        support-windows.patch
        fix-dependency-libmodman.patch
        fix-install-py.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tools BUILD_TOOLS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
        -DWITH_WEBKIT3=OFF
        -DFORCE_SYSTEM_LIBMODMAN=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/Modules)
vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
          ${CMAKE_CURRENT_LIST_DIR}/usage
          DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE_RECURSE ${LIBPROXY_TOOLS} ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
