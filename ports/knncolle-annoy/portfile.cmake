vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knncolle/knncolle_annoy
    REF "v${VERSION}"
    SHA512 cb56acebdc8fcb148f17c43223c0deb7f8f70047f692c6ddbc86101fd8967ae79ab1755b82a4982d1f63275a0abecb96d5fa0bffa04ff62d2689189684d26e69
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKNNCOLLE_ANNOY_FETCH_EXTERN=OFF
        -DKNNCOLLE_ANNOY_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME knncolle_annoy
    CONFIG_PATH lib/cmake/knncolle_annoy
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
