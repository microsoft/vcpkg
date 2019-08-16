include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO khizmax/libcds
    REF v2.3.3
    SHA512 95e67da4336d622d47bdf124d76827ca3e82e65ab5f725ccf58c2d7957960e7d17ee1ebb2126eed70f7a3ca1c97f840d9f59c1ae2eb80215d10abf70b215e510
    HEAD_REF master
    PATCHES
        001-cmake-install.patch
        002-lib-suffix-option.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DISABLE_INSTALL_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" DISABLE_INSTALL_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_UNIT_TEST=OFF
        -DENABLE_STRESS_TEST=OFF
        -DDISABLE_INSTALL_STATIC=${DISABLE_INSTALL_STATIC}
        -DDISABLE_INSTALL_SHARED=${DISABLE_INSTALL_SHARED}
        "-DLIB_SUFFIX="
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/LibCDS)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libcds RENAME copyright)

vcpkg_copy_pdbs()
