if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/sentencepiece
    REF "v${VERSION}"
    SHA512 31dc4dc3f2ff4a7effc1ed2d6ad219bcd5d28c0bac89fdeae0336f23e93f954c597313788529e692a0d694d5fa7c3c285a485dfb84a96921efc4b49bcd465358
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSPM_ENABLE_SHARED=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
if(NOT VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_BUILD_TYPE)
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/sentencepiece.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/sentencepieced.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/sentencepiece_train.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/sentencepiece_traind.lib")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
