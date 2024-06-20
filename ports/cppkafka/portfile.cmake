vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mfontanini/cppkafka
    REF "${VERSION}"
    SHA512 86ac1500bdf6746a5e44e9ca4a4063eabcacec68b26c6846f7e7d47fe947309fc98a47986ab060d793096665d1cdc24044334267eb579cdb191f539bf96a3294
    HEAD_REF master
    PATCHES
        0001-Fix-static-lib.patch
        0002-Remove-min-max-macros.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(CPPKAFKA_BUILD_SHARED OFF)
    set(CPPKAFKA_RDKAFKA_STATIC_LIB ON)
else()
    set(CPPKAFKA_BUILD_SHARED ON)
    set(CPPKAFKA_RDKAFKA_STATIC_LIB OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS 
       -DCMAKE_CXX_STANDARD=11
       -DCPPKAFKA_BUILD_SHARED=${CPPKAFKA_BUILD_SHARED}
       -DCPPKAFKA_DISABLE_TESTS=ON
       -DCPPKAFKA_DISABLE_EXAMPLES=ON
       -DCPPKAFKA_PKGCONFIG_DIR=lib/pkgconfig
       -DCPPKAFKA_RDKAFKA_STATIC_LIB=${CPPKAFKA_RDKAFKA_STATIC_LIB}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/CppKafka
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_fixup_pkgconfig()
