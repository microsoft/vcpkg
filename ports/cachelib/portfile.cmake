vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/CacheLib
    REF "v${VERSION}"
    SHA512 8c3146ac431354c2569ac63f8a39e70738072fd2768532547dd5a00bcb13c2db6efe22f2f0d31c4777ff2a86c6cdad28b0dfdc121d876d83bfd0ab2397a1d397
    HEAD_REF main
    PATCHES
        fix-build.patch
        fix-glog.patch
)

FIND_PATH(NUMA_INCLUDE_DIR NAME numa.h
    PATHS ENV NUMA_ROOT
    HINTS "$ENV{HOME}/local/include" /opt/local/include /usr/local/include /usr/include
)

IF (NOT NUMA_INCLUDE_DIR)
    MESSAGE(FATAL_ERROR "Numa library not found.\nTry: 'sudo yum install numactl numactl-devel' (or sudo apt-get install libnuma1 libnuma-dev)")
ENDIF ()

file(REMOVE "${SOURCE_PATH}/cmake/FindGlog.cmake")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cachelib"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DCMAKE_INSTALL_DIR=share/cachelib
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cachelib PACKAGE_NAME cachelib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
