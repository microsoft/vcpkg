vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/CacheLib
    REF "v${VERSION}"
    SHA512 0290b51ac3461ae7622f5e916a44f005cf55dded1c7f36ca84e98dbb806f876bde97f187a31f5b0015fe1cc6fc6baa57eb5ecba6ebfa71b86e6a828d299c9763
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
        -DVCPKG_LOCK_FIND_PACKAGE_uring=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cachelib PACKAGE_NAME cachelib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
