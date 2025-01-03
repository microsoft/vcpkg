vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nibanks/msh3
    REF #[[ v${VERSION} ]] ba595031e093b479beaa0f410cb70405bc5fd067
    SHA512 e882079ab7996c458af8af9c5d828172217591832621bd2a4353a6a6821dc16cf221253a3041e42e94bf9972bcd6a812d8fbe8eb1a02c84cb21cd95edf29fe66
    HEAD_REF main
    PATCHES
        win32-crt.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMSH3_INSTALL_PKGCONFIG=ON
        -DMSH3_USE_EXTERNAL_LSQPACK=ON
        -DMSH3_USE_EXTERNAL_MSQUIC=ON
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
