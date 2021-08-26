vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.xiph.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/ogg
    REF v1.3.5
    SHA512 72bfad534a459bfca534eae9b209fa630ac20364a82e82f2707b210a40deaf9a7dc9031532a8b27120a9dd66f804655ddce79875758ef14b109bf869e57fb747
    HEAD_REF master
)

if(VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string(${SOURCE_PATH}/win32/ogg.def "LIBRARY ogg" "LIBRARY libogg")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DINSTALL_DOCS=0 -DINSTALL_PKG_CONFIG_MODULE=1
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Ogg TARGET_PATH share/ogg)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

