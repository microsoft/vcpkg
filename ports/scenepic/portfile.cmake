vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  microsoft/scenepic 
    REF "v${VERSION}"
    SHA512 2d9dfcefa7a054cf0addb12113ab65cb7dd3a8a6f7b42f60558a5d47a6de45a9e801be3266b81358ff8ac075dd9e9e2b9369905d62f2383531d6e28e93406ac9
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

