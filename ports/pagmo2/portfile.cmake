vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO esa/pagmo2 
    REF v2.17.0
    SHA512 8fea7fcb5499b0406f862b90eb8b5900bf4b3b0fa622dfd20d1349f6b556a75001d99ebef61fcb8f35fdc0958b6c5a61d9f6ae80b828ef44dc3f0d5bda176235
    HEAD_REF master
    PATCHES
        "disable-C4701.patch"
        "disable-md-override.patch"
        "find-tbb.patch"
)

file(REMOVE ${SOURCE_PATH}/cmake_modules/FindTBB.cmake)

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

