vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/glog
    REF v0.5.0
    SHA512 445e4338f3d81cd0b065f2da9c6ce343c243263ca144cea424ef97531a4e9e09c06ffd6942ac01c5213a8003c75cfbbede3c4028d12f0134f23ff29314769c1a
    HEAD_REF master
    PATCHES
       glog_disable_debug_postfix.patch
       fix_glog_CMAKE_MODULE_PATH.patch
       fix_log_every_n.patch
       nogdi-nominmax.patch

)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/glog)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
