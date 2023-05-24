vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  microsoft/scenepic 
    REF "v${VERSION}"
    SHA512 2ec8cdaa54a4432386175c545c4114d0682015cb34f77968622eac0b9ef6ccd8a5f14ba663339995bf109b472958407f694d40adf6025c02e464e94ef4fe5bd0
    HEAD_REF main
    PATCHES
        "fix_dependencies.patch"
        "fix-CMakeInstall.patch"
)

# Run npm install and npm run build on the cloned project    
execute_process(
    COMMAND npm install
    WORKING_DIRECTORY "${SOURCE_PATH}"
)
execute_process(
    COMMAND npm run build
    WORKING_DIRECTORY "${SOURCE_PATH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DCPP_TARGETS=cpp
)   
  
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/README.md"
                    "${CURRENT_PACKAGES_DIR}/debug/CHANGELOG.md"
                    "${CURRENT_PACKAGES_DIR}/README.md"
                    "${CURRENT_PACKAGES_DIR}/CHANGELOG.md"
                    "${CURRENT_PACKAGES_DIR}/debug/include")

