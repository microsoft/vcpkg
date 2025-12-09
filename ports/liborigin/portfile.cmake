vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liborigin
    REF liborigin/3.0
    FILENAME liborigin-${VERSION}.tar.gz
    SHA512 44157e1a5c71d7344e58c4702a43fd315978bff74992e1d7c568517c0685f617062777c791d6089872197d30f20cc06617aa4bd31d6a458df97b27eacf2f0f19
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(LIB_OPTION "-DBUILD_STATIC_LIBS=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${LIB_OPTION}
)

vcpkg_cmake_build()

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES opj2dat AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
