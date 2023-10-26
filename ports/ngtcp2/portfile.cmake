vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ngtcp2/ngtcp2
    REF "v${VERSION}"
    SHA512 c76ede7546d0d7056281002149441e5722147c31c934266dbb50c821ba6c1c493c798e636c84b2d76e925a9cdf7f5b34dd7e9fa1f0ba674453ece26130acc9cf
    HEAD_REF master
    PATCHES
      export-unofficical-target.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DENABLE_STATIC_LIB=${ENABLE_STATIC_LIB}"
        "-DENABLE_SHARED_LIB=${ENABLE_SHARED_LIB}"
        -DENABLE_OPENSSL=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Libev=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Libnghttp3=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_CUnit=ON
        -DCMAKE_INSTALL_DOCDIR=share/ngtcp2
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-ngtcp2)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
