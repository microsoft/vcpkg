vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  esa/pagmo2 
    REF v2.16.1
    SHA512 dac85a8525316e827df809d187d40f14dc20db7119796b7384d7855f83ba37e0bb595f6d8199053aac857460816929dd599c9d43802f2ed920a6f42dd2f16a03
    HEAD_REF master
    PATCHES
        "disable-C4701.patch"
        "disable-md-override.patch"
        "find-tbb.patch"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
   FEATURES
   nlopt  PAGMO_WITH_NLOPT
)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PAGMO_BUILD_STATIC_LIBRARY)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPAGMO_WITH_EIGEN3=ON
        -DPAGMO_BUILD_STATIC_LIBRARY=${PAGMO_BUILD_STATIC_LIBRARY}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/pagmo)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING.lgpl3 DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

