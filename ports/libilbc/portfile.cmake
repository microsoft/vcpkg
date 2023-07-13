set(ILBC_VERSION 3.0.4)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TimothyGu/libilbc
    REF cd064edf2c6c104a4e1fd87b34fd24cfa6dbe401
    SHA512 323d32dbd54d5ef624940432bf19c29f5ead6f40bc84aba4261f067dfdc40cf4000e383f4dca65cd3b745a354a119a9e515949a1466af89c300cd7bf95991675
    PATCHES
        do-not-build-ilbc_test.patch
        absl.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_INSTALL_DOCDIR=share/${PORT}
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ilbc_export.h" "#ifdef ILBC_STATIC_DEFINE" "#if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
