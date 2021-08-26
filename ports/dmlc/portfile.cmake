vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dmlc/dmlc-core
    REF d3fd7c5e9b9c280d3081ada3fb62705547c00bf1
    SHA512 6887d52ddd00949866c27bea3c860abb8a7ecf61feeac79d67d260635e9c3e490b6f0538cbc0ccc1f03e90ab4094bfc0fcb938adb3fb5afe9fea813d47cc7430
    HEAD_REF master
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
       -DDMLC_FORCE_SHARED_CRT=${DMLC_FORCE_SHARED_CRT}
       -DUSE_OPENMP=${ENABLE_OPENMP}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/dmlc)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
