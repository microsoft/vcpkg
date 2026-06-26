vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  microsoft/scenepic 
    REF "v${VERSION}"
    SHA512 13beecaa8eb218f53b617ce4babe70292a3056f649d5dd85c8b7bfda6e870df147afe50dba228b8a0e460cebf1e2d051318004c9ec0f2a70b9349c5016a5364d
    HEAD_REF main
    PATCHES
        0001-fix-dependencies.patch
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

