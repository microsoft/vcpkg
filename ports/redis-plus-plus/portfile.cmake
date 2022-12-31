vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sewenew/redis-plus-plus
    REF 39f5a515d048cc5ef897aaf319ddffb54ae9427c # 1.3.6
    SHA512 f02fd77e9c8964cb0503e1a99edeaa793f4cf9365ef20b25ebf10001c1ed1fa9a6e90314092d9fb545a60168eb5bade161d57b17bb74068bdd52d356e484a505
    HEAD_REF master
    PATCHES
        fix-conversion.patch
        fix-dependency-libuv.patch
)

if("cxx17" IN_LIST FEATURES)
    set(REDIS_PLUS_PLUS_CXX_STANDARD 17)
else()
    set(REDIS_PLUS_PLUS_CXX_STANDARD 11)
endif()

set(EXTRA_OPT "")
if ("async" IN_LIST FEATURES)
    list(APPEND EXTRA_OPT -DREDIS_PLUS_PLUS_BUILD_ASYNC="libuv")
endif()
if ("async-std" IN_LIST FEATURES)
    list(APPEND EXTRA_OPT -DREDIS_PLUS_PLUS_ASYNC_FUTURE="std")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" REDIS_PLUS_PLUS_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" REDIS_PLUS_PLUS_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DREDIS_PLUS_PLUS_USE_TLS=OFF
        -DREDIS_PLUS_PLUS_BUILD_STATIC=${REDIS_PLUS_PLUS_BUILD_STATIC}
        -DREDIS_PLUS_PLUS_BUILD_SHARED=${REDIS_PLUS_PLUS_BUILD_SHARED}
        -DREDIS_PLUS_PLUS_BUILD_TEST=OFF
        -DREDIS_PLUS_PLUS_CXX_STANDARD=${REDIS_PLUS_PLUS_CXX_STANDARD}
        ${EXTRA_OPT}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright )

vcpkg_fixup_pkgconfig()
