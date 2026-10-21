vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liborigin
    REF liborigin/3.0
    FILENAME "liborigin-${VERSION}.tar.gz"
    SHA512 3b0d02c39bd4d0faa28808feb943c6dd696532b9391bc0a2fd55732931a18c8d1a66e38f520ad6cbdaecb0c33149a5e2b873403cc8a663b46e0f5a7db3d2b14f
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(LIB_OPTION "-DBUILD_STATIC_LIBS=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${LIB_OPTION}
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_cmake_build()

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES opj2dat AUTO_CLEAN)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
