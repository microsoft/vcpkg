include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/FastLZ-master)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ariya/FastLZ/archive/master.zip"
    FILENAME "fastlz.zip"
    SHA512 2e7928a08b00c80b3a19936db1b2c7030b021e143db4811299b2548846499c735280e77fb101cb060031415c19028722add4c6ed86c1ddde3cd0d0de3f45d522
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fastlz)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/fastlz/LICENSE ${CURRENT_PACKAGES_DIR}/share/fastlz/copyright)
vcpkg_copy_pdbs()
