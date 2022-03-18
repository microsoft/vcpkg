vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DanBloomberg/leptonica
    REF 2ff4313a85427ceb272540c570106b2f893da097 # 1.81.1
    SHA512 0e35538f1407e7220e68d635e5fd4c82219b58fb4b6ca8132d72892f52853e13451a2a160644a122c47598f77d2e87046cfb072be261be9a941342f476dc6376
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
        fix-src-cmakelists.patch
        find-dependency.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSW_BUILD=OFF
        -DCPPAN_BUILD=OFF
        -DSTATIC=${STATIC}
        -DCMAKE_REQUIRED_INCLUDES=${CURRENT_INSTALLED_DIR}/include # for check_include_file()
    MAYBE_UNUSED_VARIABLES
        STATIC
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/leptonica-license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
