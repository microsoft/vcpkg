# header only
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/beast-1.0.0-b30)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/vinniefalco/Beast/archive/v1.0.0-b30.zip"
    FILENAME "beast-1.0.0-b30.zip"
    SHA512 af801748efabafef1b7ae817be9da9480dcf881b3037f92e5997e42255399bd7b22772bb2a5c9aab7d01c31c7995c4d23a41f4b7f6ccdef18d9a8a15906fd43f
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/beast RENAME copyright)