string(REPLACE "." "_" UNDERSCORE_VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openfx
    REF "OFX_Release_${UNDERSCORE_VERSION}_TAG"
    SHA512 b20512ea38823167f191b72f1592548df85fbda6cefe47673972874c139641ee91277e78c1e0d57a457b9f864385e6fa0e4a7edcdbf0c7b2eda956c03a3e1e13
    HEAD_REF main
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-openfx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/DocSrc")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Support/LICENSE")
