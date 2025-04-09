vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.xiph.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/ogg
    REF v1.3.5
    SHA512 72bfad534a459bfca534eae9b209fa630ac20364a82e82f2707b210a40deaf9a7dc9031532a8b27120a9dd66f804655ddce79875758ef14b109bf869e57fb747
    HEAD_REF master
)

if(VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${SOURCE_PATH}/win32/ogg.def" "LIBRARY ogg" "LIBRARY libogg")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 #https://gitlab.xiph.org/xiph/ogg/-/issues/2304
        -DINSTALL_DOCS=OFF
        -DINSTALL_PKG_CONFIG_MODULE=ON
        -DBUILD_TESTING=OFF
    MAYBE_UNUSED_VARIABLES
        CMAKE_POLICY_VERSION_MINIMUM
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Ogg PACKAGE_NAME ogg)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
