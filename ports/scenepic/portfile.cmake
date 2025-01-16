vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  microsoft/scenepic 
    REF "v${VERSION}"
    SHA512 79c20697051ef7061a51cc73f232e5ba83f8bc5a62ee3b9a4d55182112b201c805c25461fcd6699cc6db70c4439b116d1d27e66cd4e431471438ac7968836eed
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

