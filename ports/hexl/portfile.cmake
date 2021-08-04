# This library only supports "x64" architecture
vcpkg_fail_port_install(ON_ARCH "x86" "arm" "arm64")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/hexl
    REF 2dc1db6824be3fc89d13740efd0270ec9afec77e
    SHA512 aaa80dc53a21586d763a2b84b40d60062020470988422601bc5e9c2b31c6263847a97ea8f956d002a95e2d5e843cafa96fabdfd8b8ee892c7a7b9747133adebb
    HEAD_REF main
    PATCHES
        disable_downloading_cpu_features.patch
        find_dependency_cpu_features.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(HEXL_SHARED OFF)
else()
    set(HEXL_SHARED ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DHEXL_DEBUG=OFF"
        "-DHEXL_BENCHMARK=OFF"
        "-DHEXL_EXPORT=ON"
        "-DHEXL_COVERAGE=OFF"
        "-DHEXL_TESTING=OFF"
        "-DHEXL_SHARED_LIB=${HEXL_SHARED}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "HEXL" CONFIG_PATH "lib/cmake")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

vcpkg_copy_pdbs()
