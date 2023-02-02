if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/sentencepiece
    REF 58f256cf6f01bb86e6fa634a5cc560de5bd1667d #v0.1.97
    SHA512 9abe21f76aa025d35a0210bc1a5b0c6f2bb2ab9f626ef9d59bcd8950442036af048ca3945db311d80ff378d41f984a941f39c206e2aa006f1ca0278426d03932
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

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
