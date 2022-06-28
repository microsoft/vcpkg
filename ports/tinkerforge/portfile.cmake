set(VERSION 2_1_25)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.tinkerforge.com/bindings/c/tinkerforge_c_bindings_${VERSION}.zip"
    FILENAME "tinkerforge-${VERSION}.zip"
    SHA512  c02b789bd466803d60aeb39a544b0aa17af811377b065a0b273bcfc15c5844f8cfe981d8143743e32bd05470c2c6af297df50924da0d2895a4cdf4bc9e9bd0b8
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF tinker-${VERSION}
    NO_REMOVE_ONE_LEVEL
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION ${SOURCE_PATH})
file(COPY "${CMAKE_CURRENT_LIST_DIR}/tinkerforgeConfig.cmake.in" DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
