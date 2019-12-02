vcpkg_fail_port_install(ON_TARGET "UWP")

# Enable static build in UNIX
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fail_port_install(ON_LIBRARY_LINKAGE "static")
endif()

set(LIBMODMAN_VER 2.0.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/libmodman/libmodman-${LIBMODMAN_VER}.zip"
    FILENAME "libmodman-${LIBMODMAN_VER}.zip"
    SHA512 1fecc0fa3637c4aa86d114f5bc991605172d39183fa0f39d8c7858ef5d0d894152025bd426de4dd017a41372d800bf73f53b2328c57b77352a508e12792729fa
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        fix-install-path.patch
        fix-undefined-typeid.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/libmodman)
vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
          ${CMAKE_CURRENT_LIST_DIR}/usage
          DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
