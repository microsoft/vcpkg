vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/CacheLib
    REF dd0af61a5fcb621ac253f67715b5fad8994627c7 # v2023.02.27.00
    SHA512 24b40f16c281df2784fea260b66040a716a80603d61fe5cb666fca72c305a3568f63353a18bf4913a379e7e0b78eb35d5b22889315ec48d400de8f1f6a2fc018
    HEAD_REF master
    PATCHES
        fix-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cachelib"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DCMAKE_INSTALL_DIR=share/unofficial-cachelib
)

vcpkg_cmake_install()
# vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/unofficial-cachelib PACKAGE_NAME unofficial-cachelib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()

