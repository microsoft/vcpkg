vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mfontanini/cppkafka
    REF "v${VERSION}"
    SHA512 dce4da452cb98d854714a0ab7ab5e85a078d5e1c023c05344ea1a63d08112c25d32a6209bc29cfbaefc2b26abfab02e72081baa68528a23ec610c208f4d34d9f
    HEAD_REF master
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
