if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    message(FATAL_ERROR "ARM build not supported")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lzfse/lzfse
    REF lzfse-1.0
    SHA512 9d7ca44e6d3d2bdf4b82b0eb66c14922369b8b6fe2cf891187a77c6708b8d26c2c1b2ccddec6059e85dbbbb37c497419549f02812b5f34d06238ac246a8cf912
    HEAD_REF master
    PATCHES
        disable-cli-option.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLZFSE_DISABLE_TESTS=ON
        -DLZFSE_DISABLE_CLI=ON)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(READ "${CURRENT_PACKAGES_DIR}/include/lzfse.h" LZFSE_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(REPLACE "defined(LZFSE_DLL)" "1" LZFSE_H "${LZFSE_H}")
else()
    string(REPLACE "defined(LZFSE_DLL)" "0" LZFSE_H "${LZFSE_H}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/lzfse.h" "${LZFSE_H}")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
