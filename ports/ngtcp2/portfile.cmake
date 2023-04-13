vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ngtcp2/ngtcp2
    REF "v${VERSION}"
    SHA512 6bfcae1d7c782931093541156ebd6e736843b5df13362aa5468daa72f74bad33d0f1aa2aafc6f4d138cdd34d6a367e2ff12efedfd6dfa5b8811e4cdebaca0016
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
        -DCMAKE_DISABLE_FIND_PACKAGE_GnuTLS=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenSSL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_wolfssl=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Jemalloc=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Libev=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Libnghttp3=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_CUnit=ON
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_GnuTLS
        CMAKE_DISABLE_FIND_PACKAGE_Jemalloc
        CMAKE_DISABLE_FIND_PACKAGE_wolfssl
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/unofficial-ngtcp2")

# Clean
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

#License
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
