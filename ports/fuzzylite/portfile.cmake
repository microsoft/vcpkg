vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fuzzylite/fuzzylite
    REF v6.0
    SHA512 6f5d40d0359458e109ac2aebfbf571f61867a8b49920f4a5e1b5d86bdf578dba038b942c9e05eab0d4620f73e8cded770abe7b5e597a3b4c39dbcf6a1259f4af
    HEAD_REF master
    PATCHES
        no-werror.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" FL_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" FL_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/fuzzylite"
    OPTIONS
        -DFL_BUILD_SHARED=${FL_BUILD_SHARED}
        -DFL_BUILD_STATIC=${FL_BUILD_STATIC}
        -DFL_BUILD_BINARY=OFF
        -DFL_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/fl/fuzzylite.h"
        "#elif defined(FL_IMPORT_LIBRARY)"
        "#elif 1"
    )
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/fl/fuzzylite.h"
        "#elif defined(FL_IMPORT_LIBRARY)"
        "#elif 0"
    )
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
