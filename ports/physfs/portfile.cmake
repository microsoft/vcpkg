vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO icculus/physfs
    REF eb3383b532c5f74bfeb42ec306ba2cf80eed988c # release-3.2.0
    SHA512 4231b379107a8dbacad18d98c0800bad4a3aae1bdd1db0bd4cf0c89c69bb7590ed14422c77671c28bd7556f606d3ff155ad8432940ce6222340f647f9e73ae8e
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PHYSFS_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PHYSFS_SHARED)

if(VCPKG_TARGET_IS_UWP)
    set(configure_opts WINDOWS_USE_MSBUILD)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    ${configure_opts}
    OPTIONS
        -DPHYSFS_BUILD_STATIC=${PHYSFS_STATIC}
        -DPHYSFS_BUILD_SHARED=${PHYSFS_SHARED}
        -DPHYSFS_BUILD_TEST=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PhysFS)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
