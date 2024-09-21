vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO waywardgeek/sonic
    REF "release-${VERSION}"
    SHA512 e70510c89c4f29c30f2a3443a1c4fc1aab2c99147e2ebd1dea3cbb2b89b8bdcee14dc504600ac1f04e82d32c19f17b06fbb417311853beb764c24d15687a126f
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tool BUILD_TOOL
)


file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TOOL=${BUILD_TOOL}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(BUILD_TOOL)
    vcpkg_copy_tools(TOOL_NAMES sonic AUTO_CLEAN)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
