# This library only supports "x64" architecture
vcpkg_fail_port_install(ON_ARCH "x86" "arm" "arm64")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/hexl
    REF bb4b6a630e0c48d04183650247f40ae90217bdf5
    SHA512 5e4fe1f5f9ba03de9bc6f1da1064df96ff89f6520c0759af62db81c600a980e5c91f8325243413e2df08d42c8d4af7c67998eb4a9c66d8ff7118132563cbbb32
    HEAD_REF 1.2.1
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(HEXL_SHARED OFF)
else()
    set(HEXL_SHARED ON)
endif()

vcpkg_find_acquire_program(GIT)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DHEXL_BENCHMARK=OFF"
        "-DHEXL_COVERAGE=OFF"
        "-DHEXL_TESTING=OFF"
        "-DHEXL_SHARED_LIB=${HEXL_SHARED}"
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME "HEXL" CONFIG_PATH "lib/cmake/hexl-1.2.1")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

vcpkg_copy_pdbs()
