vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dmlc/dmlc-core
    REF dfd9365264a060a5096734b7d892e1858b6d2722
    SHA512 0dc2ecd3c981d88de27bf5184f7b380261335c474934d0db59028adfe75f6b3ee2da5b831135acfaad7943acb3eaa7007c0faf0f14e63b39865354898f64fcea
    HEAD_REF main
    PATCHES
        cxx-fix.patch # from https://github.com/dmlc/dmlc-core/pull/676
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp    ENABLE_OPENMP
)

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
   set(DMLC_FORCE_SHARED_CRT ON)
else()
   set(DMLC_FORCE_SHARED_CRT OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
       -DDMLC_FORCE_SHARED_CRT=${DMLC_FORCE_SHARED_CRT}
       -DUSE_OPENMP=${ENABLE_OPENMP}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/dmlc)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
