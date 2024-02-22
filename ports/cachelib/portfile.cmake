vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/CacheLib
    REF "v${VERSION}"
    SHA512 28aa7644e240c8aeb8f19a3db6fb0de150a28a4bed4ffeb59a45522dcad60a1e1ee7818b8ef8f46a45f523ca5db93608de7d42fadfd0c006b8ec6abad58c5f0f
    HEAD_REF master
    PATCHES
        fix-build.patch
        fmt-10.patch
)

FIND_PATH(NUMA_INCLUDE_DIR NAME numa.h
    PATHS ENV NUMA_ROOT
    HINTS "$ENV{HOME}/local/include" /opt/local/include /usr/local/include /usr/include
)

IF (NOT NUMA_INCLUDE_DIR)
    MESSAGE(FATAL_ERROR "Numa library not found.\nTry: 'sudo yum install numactl numactl-devel' (or sudo apt-get install libnuma1 libnuma-dev)")
ENDIF ()

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
