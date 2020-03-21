include(vcpkg_common_functions)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.freedesktop.org/software/uchardet/releases/uchardet-0.0.6.tar.xz"
    FILENAME "uchardet-0.0.6.tar.xz"
    SHA512 eceeadae060bf277e298d709856609dde32921271140dc1fb0a33c7b6e1381033fc2960d616ebbd82c92815936864d2c0743b1b5ea1b7d4a200df87df80d6de5
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_BINARY=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/uchardet RENAME copyright)
