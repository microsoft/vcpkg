# No DLL export(yet)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO laurencelundblade/QCBOR
    REF v${VERSION}
    SHA512 e0630f5e5bc614fb87dee6d8adb32d6ea2d896bdf7074df38cb99833b2136dd7417df72bbff2a4c935def19064ea15c0895e54af5aed2ae1328e64d224e12655
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_QCBOR_TEST=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/qcbor)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
