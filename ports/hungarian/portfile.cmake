vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www2.informatik.uni-freiburg.de/~stachnis/misc/libhungarian-v0.1.3.tgz"
    FILENAME "libhungarian-v0.1.3.tgz"
    SHA512 1fa105e351c307c07bb96892c9d4c44b167d92cbed80962a8653ac35b8afe00fcf5dcc2d920b95671d6c3cd86745362a64dd8dc173623a8179006e2c7b2cbc69
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/hungarian RENAME copyright)
