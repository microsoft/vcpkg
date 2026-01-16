vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gpakosz/whereami
    REF dcb52a058dc14530ba9ae05e4339bd3ddfae0e0e
    SHA512 afd5999316c398218d8a401b6dc6a9885c9e474bde6804f464d55eca42fdee126329856da5b337bdfad5582e6ed1364fc86a47c92b49b6d57f1bea4e3d5120e0
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-whereamiConfig.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
                      OPTIONS
                      -DPROJECT_VERSION_STRING=${VERSION})
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-whereami CONFIG_PATH "lib/cmake/unofficial-whereami")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.MIT" "${SOURCE_PATH}/LICENSE.WTFPLv2")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
