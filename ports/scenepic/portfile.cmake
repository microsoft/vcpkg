vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  microsoft/scenepic 
    REF "v${VERSION}"
    SHA512 2d9dfcefa7a054cf0addb12113ab65cb7dd3a8a6f7b42f60558a5d47a6de45a9e801be3266b81358ff8ac075dd9e9e2b9369905d62f2383531d6e28e93406ac9
    HEAD_REF main
    PATCHES
        "fix_dependencies.patch"
)

# Run npm install and npm run build on the cloned project    
execute_process(
    COMMAND npm install
    WORKING_DIRECTORY ${SOURCE_PATH}
)
execute_process(
    COMMAND npm run build
    WORKING_DIRECTORY ${SOURCE_PATH}
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_BUILD_TYPE=Release
        -DVCPKG_TARGET_TRIPLET=${VCPKG_TARGET_TRIPLET}
        -DBUILD_SHARED_LIBS=OFF
        -DCPP_TARGETS=cpp
)   
  
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_cmake_config_fixup(CONFIG_PATH cmake PACKAGE_NAME scenepic)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(COPY ${CURRENT_PACKAGES_DIR}/build DESTINATION ${CURRENT_PACKAGES_DIR}/share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug
                    ${CURRENT_PACKAGES_DIR}/README.md
                    ${CURRENT_PACKAGES_DIR}/CHANGELOG.md
                    ${CURRENT_PACKAGES_DIR}/cmake
                    ${CURRENT_PACKAGES_DIR}/build)

