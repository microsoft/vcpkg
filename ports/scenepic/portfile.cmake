vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  microsoft/scenepic 
    REF v1.0.16
    SHA512 2d9dfcefa7a054cf0addb12113ab65cb7dd3a8a6f7b42f60558a5d47a6de45a9e801be3266b81358ff8ac075dd9e9e2b9369905d62f2383531d6e28e93406ac9
    HEAD_REF main
    PATCHES
        "fix_dependencies.patch"
)

#set(VCPKG_BUILD_TYPE release)



# Run npm install and npm run build on the cloned project    
execute_process(
    COMMAND npm install
    WORKING_DIRECTORY ${SOURCE_PATH}
    )
execute_process(
    COMMAND npm run build
    WORKING_DIRECTORY ${SOURCE_PATH}
    )


vcpkg_configure_cmake(
    PREFER_NINJA
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_BUILD_TYPE=Debug
        -DVCPKG_TARGET_TRIPLET=${VCPKG_TARGET_TRIPLET}
        -DBUILD_SHARED_LIBS=OFF
        -DCPP_TARGETS=cpp
)
    
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()


file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(COPY  ${CURRENT_PACKAGES_DIR}/cmake/scenepicTargets.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(COPY  ${CURRENT_PACKAGES_DIR}/cmake/scenepicConfigVersion.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(COPY  ${CURRENT_PACKAGES_DIR}/cmake/scenepicTargets-debug.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(COPY  ${CURRENT_PACKAGES_DIR}/cmake/scenepicConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE "${CURRENT_PACKAGES_DIR}/README.md")
file(REMOVE "${CURRENT_PACKAGES_DIR}/CHANGELOG.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/cmake")