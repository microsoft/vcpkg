vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dtecta/solid3
    REF c53f6bb1eaaafb1cfb305ef71b1c3a2edb4844e6
    SHA512 ae42ba75f5309fecba836e5786d4cb81eeb1240f6fd7c458c6d1329d8e1075021504b927ea0aedb66162deeb79ad674cacb0190385afe456420c0d9184596f1f
    HEAD_REF master
    PATCHES
        disable-examples.patch
        potentially-uninitialized-local-pointer-variable.patch
        no-sse.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DYNAMIC_SOLID)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDYNAMIC_SOLID=${DYNAMIC_SOLID}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/solid3)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/README.md"
        "${SOURCE_PATH}/LICENSE_GPL.txt"
        "${SOURCE_PATH}/LICENSE_QPL.txt"
)
