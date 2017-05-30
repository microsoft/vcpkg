#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/range-v3-6eb5c831ffe12cd5cb96390dbe917ca1b248772d)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ericniebler/range-v3/archive/6eb5c831ffe12cd5cb96390dbe917ca1b248772d.zip"
    FILENAME "range-v3-6eb5c831ffe12cd5cb96390dbe917ca1b248772d.zip"
    SHA512 2605af46c2c049f66dc982b1c4e506a8f115d47cc6c61a80f08921c667e52ad3097c485280ee43711c84b84a1490929e085b89cf9ad4c83b93222315210e92aa
)
vcpkg_download_distfile(DIFF
    URLS "https://github.com/Microsoft/Range-V3-VS2015/compare/fork_base...00ed689bac7a9dcd8601dbde382758675516799d.diff"
    FILENAME "range-v3-fork_base_to_00ed689bac7a9dcd8601dbde382758675516799d.diff"
    SHA512 6158cd9ee1f5957294a26dc780c881839e0bae8610688a618cd11d47df34d5e543fa09ac9a3b33d4a65af8eceae0a6a3055621206c291ef75f982e7915daf91a
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH} PATCHES ${DIFF})

file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/range-v3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/range-v3/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/range-v3/copyright)
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")
vcpkg_copy_pdbs()
