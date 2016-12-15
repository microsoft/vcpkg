set(FASTLZ_HASH f1217348a868bdb9ee0730244475aee05ab329c5)
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/FastLZ-${FASTLZ_HASH})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ariya/FastLZ/archive/${FASTLZ_HASH}.zip"
    FILENAME "fastlz-${FASTLZ_HASH}.zip"
    SHA512 edfefbf4151e7ea6451a6fbb6d464a2a0f48ab50622f936634ec3ea4542ad3e1f075892a422e0fc5a23f2092be4ec890e6f91c4622bcd0d195fed84d4044d5df
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
