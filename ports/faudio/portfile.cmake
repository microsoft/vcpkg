vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FNA-XNA/faudio
    REF cfdc4db21a9c7d21a9132da5b213248a823fbe05 # This is 24.03 with 3 patches to fix minor build failures by @rkitover and @dg0yt
    SHA512 9f7ee882e9aa7cf80d976e2c016aa085222d21da2b0fac0e59f5a713e3a3dd41deb2dfc1a4698a3eff0b46bb122eca874fbd5b2747c243c53118bae3c5af9ef9
    HEAD_REF master
    PATCHES
)

set(options "")
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND options -DPLATFORM_WIN32=TRUE)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FAudio)

vcpkg_install_copyright(
    COMMENT "FAudio is licensed under the Zlib license."
    FILE_LIST
       "${SOURCE_PATH}/LICENSE"
)
