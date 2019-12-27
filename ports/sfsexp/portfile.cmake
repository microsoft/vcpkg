if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mjsottile/sfsexp/releases/download/v1.3/sexpr-1.3.tar.gz"
    FILENAME "sexpr-1.3.tar.gz"
    SHA512 ce02b18b9a48d8a29788f9c46f4693e5d0bb9b097bc6f6d03d79744bb9b3c312eff37d90275b02b9a64daf6e04feaeb97a8d657090b4f3a9818afc2f6b7d10da
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/sfsexp RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)