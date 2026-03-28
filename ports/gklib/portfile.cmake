if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KarypisLab/GKlib
    REF "METIS-v${VERSION}"
    SHA512 248db76a51c66ae9b94ac759e19f6e5504dd75d6e1b3a1c0f8a1f2db899099ec7b62328213bfdefef8c70b6be40f122a27d427c016cbf4419fd1e032a52567ca
    PATCHES
        build-fixes.patch
        regex.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_INSTALL_INCLUDEDIR=include/GKlib
        -DGKLIB_BUILD_APPS=OFF
        -DSHARED=${SHARED}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/GKlib")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
