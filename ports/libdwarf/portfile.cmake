vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO davea42/libdwarf-code
    REF "v${VERSION}"
    SHA512 3117c69cc77d5a1189aeb1ea7e74d917dedfb84e9e9e98e3df7fec930f8183d12f55bb12e4871ed3746cdb19a29aba924bc73d6334b23bbb6413a1f4be67d499
    HEAD_REF main
    PATCHES v0.8.0-patches.patch
)

vcpkg_list(SET options)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_list(APPEND options -DBUILD_NON_SHARED=Off)
else()
  vcpkg_list(APPEND options -DBUILD_NON_SHARED=On)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${options}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "libdwarf"
    CONFIG_PATH "lib/cmake/libdwarf"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
#file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(
        REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/lib"
        "${CURRENT_PACKAGES_DIR}/lib"
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
