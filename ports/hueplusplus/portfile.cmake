vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO enwi/hueplusplus
    REF "v${VERSION}"
    SHA512 13995056d3f0bda645bd2eb76426d044065057c4ffe8abbd36875459f1db8c2a04c0908ebb6ebeeb2730dabf126a17c6ac01c7cd2f2fdd0c7857ef02c550ca4f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

if(VCPKG_HOST_IS_<WIN32> AND NOT CYGWIN)
    vcpkg_cmake_config_fixup(CONFIG_PATH "cmake")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/cmake")
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/hueplusplus")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/hueplusplus")
endif()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin/")
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/hueplusplusshared.dll" "${CURRENT_PACKAGES_DIR}/bin/hueplusplusshared.dll")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/hueplusplusshared.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/hueplusplusshared.dll")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")