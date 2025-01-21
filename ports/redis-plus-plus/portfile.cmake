vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sewenew/redis-plus-plus
    REF "${VERSION}"
    SHA512 c2892ec1b2f242ee19c727cd9dd1bc4e08b9f515f5736bffee5b5a12a2f1b2eddec0ebeba7998a5abc5620bdff37b5d745abdf0d7586b89535ce0ae035988ef4
    HEAD_REF master
    PATCHES
        fix-conversion.patch
        fix-dependency-libuv.patch
        fix-absolute-path.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "tls"   REDIS_PLUS_PLUS_USE_TLS
)

if("cxx17" IN_LIST FEATURES)
    set(REDIS_PLUS_PLUS_CXX_STANDARD 17)
else()
    set(REDIS_PLUS_PLUS_CXX_STANDARD 11)
endif()

set(EXTRA_OPT "")
if ("async" IN_LIST FEATURES)
    list(APPEND EXTRA_OPT "-DREDIS_PLUS_PLUS_BUILD_ASYNC=libuv")
endif()
if ("async-std" IN_LIST FEATURES)
    list(APPEND EXTRA_OPT "-DREDIS_PLUS_PLUS_ASYNC_FUTURE=std")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" REDIS_PLUS_PLUS_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" REDIS_PLUS_PLUS_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DREDIS_PLUS_PLUS_BUILD_STATIC=${REDIS_PLUS_PLUS_BUILD_STATIC}
        -DREDIS_PLUS_PLUS_BUILD_SHARED=${REDIS_PLUS_PLUS_BUILD_SHARED}
        -DREDIS_PLUS_PLUS_BUILD_TEST=OFF
        -DREDIS_PLUS_PLUS_CXX_STANDARD=${REDIS_PLUS_PLUS_CXX_STANDARD}
        ${EXTRA_OPT}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME redis++ CONFIG_PATH share/cmake/redis++)

if("async" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/redis++/redis++-config.cmake"
"include(CMakeFindDependencyMacro)"
[[include(CMakeFindDependencyMacro)
find_dependency(libuv CONFIG)]])
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
