vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ngtcp2/ngtcp2
    REF "v${VERSION}"
    SHA512 b2da92da68424678c4c2f24da3fff88d425a5db231f12f44f979da97f1ed65945e2775f730d8d397d82c39047f4d7c8045d667450ac6822392f4bb99f6224a1f
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
