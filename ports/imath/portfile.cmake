vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/Imath
    REF v3.1.9
    SHA512 ad96b2ac306fc13c01e8ea3256f885499c3f545be327feaba0f5e093b70b544bcca6f8b353fa7e35107aae515c19caced44331a95d0414f367ead4691ec73564
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIMATH_INSTALL_SYM_LINK=OFF
        -DBUILD_TESTING=OFF
        -DIMATH_INSTALL_PKG_CONFIG=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Imath)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
