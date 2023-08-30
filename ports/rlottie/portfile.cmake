vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Samsung/rlottie
    REF v0.2
    SHA512 1f645ae998ddbe83e4911addf28ec24ae3ff33f6439a9fb6c1e56986b46ac17dba155773ab02a59712e781febb31709a99075a3fbcda6136a0cb43dbd7c753de
    HEAD_REF master
    PATCHES
        "patches/01_fix_install.patch"
        "patches/02_add_limits.patch"
        "patches/03_fix_arm_neon.patch"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(LOTTIE_MODULE OFF)
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(LOTTIE_MODULE ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLOTTIE_MODULE=${LOTTIE_MODULE}
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
