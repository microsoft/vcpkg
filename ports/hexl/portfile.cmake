# This library only supports "x64" architecture
vcpkg_fail_port_install(ON_ARCH "x86" "arm" "arm64")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/hexl
    REF 5243647de9181dc04c8f7be317f7f2f2756e7319
    SHA512 0b39635f8ddb4a745492ae7f97f8ebd961346e7d87f74c5d6f8ec543a083628c855db2119810fea6f151e05d4deccdd22ed9301d2c9ed38997fcbf315690a0f7
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
