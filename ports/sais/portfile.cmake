
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/sais-2.4.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://sites.google.com/site/yuta256/sais-2.4.1.zip"
    FILENAME "sais-2.4.1.zip"
    SHA512 6f6dd11f842f680bebc1d9b7f6b75752c9589c600fdd5e6373bb7290a686f1de35d4cc3226347e717f89a295363f7fee0ae8b1aa05ad341f4c2ea056fb5b1425
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DBUILD_SAIS64=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)



# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/sais RENAME copyright)
