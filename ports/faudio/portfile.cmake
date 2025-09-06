vcpkg_download_distfile(FIND_DEPENDENCY_FIX
    URLS https://github.com/FNA-XNA/FAudio/commit/29b82ac28b3c83b5044962e88ea080875f73aebd.diff?full_index=1
    FILENAME faudio-find-dependency-fix-29b82ac28b3c83b5044962e88ea080875f73aebd.diff
    SHA512 001ba2f61a388c634fd927497109f333e86dbdecef6908c64827b6b467bb707df0c17a01054ab0a5c0a74cd1a02d61f888b6938932c871a850a418de40fa9e78
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FNA-XNA/faudio
    REF "${VERSION}"
    SHA512 f5acd68969e918a70ca59e2f9ef9f1c0c528a07d10537525c440247ccda0d11af7e079a815a17352f35e28c11abb33b6a926db44e87eeaa1f6910c8f0dee9ad4
    HEAD_REF master
    PATCHES
        "${FIND_DEPENDENCY_FIX}"
)

set(options "")
if(VCPKG_TARGET_IS_WINDOWS AND "native" IN_LIST FEATURES)
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

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FAudio)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(
    COMMENT "FAudio is licensed under the Zlib license."
    FILE_LIST
       "${SOURCE_PATH}/LICENSE"
)
