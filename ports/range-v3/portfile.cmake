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
    SHA512 615a53ebac22df03e865bdcc86580914c4505ec5fc691b6a2f864f7bf63690b99d0da0db2d5b1026e34b0a3f7557f30dfa0cad65643bae0b53c0ec066af9eb8e
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH} PATCHES ${DIFF})

file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/range-v3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/range-v3/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/range-v3/copyright)
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")
vcpkg_copy_pdbs()
