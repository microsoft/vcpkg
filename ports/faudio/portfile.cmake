vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FNA-XNA/faudio
    REF "${VERSION}"
    SHA512 d8fb3c2303c81163a26f437edce5ae428f4769a28107eb21f1fdb637421480928fc6f0031fc053caa762db901d659336a6e2ffad78ece9ab03ba4f312b00deb6
    HEAD_REF master
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
