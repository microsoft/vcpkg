include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/range-v3-6eb5c831ffe12cd5cb96390dbe917ca1b248772d)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ericniebler/range-v3/archive/6eb5c831ffe12cd5cb96390dbe917ca1b248772d.zip"
    FILENAME "range-v3-6eb5c831ffe12cd5cb96390dbe917ca1b248772d.zip"
    SHA512 2605af46c2c049f66dc982b1c4e506a8f115d47cc6c61a80f08921c667e52ad3097c485280ee43711c84b84a1490929e085b89cf9ad4c83b93222315210e92aa
)
vcpkg_download_distfile(DIFF
    URLS "https://github.com/Microsoft/Range-V3-VS2015/compare/fork_base...2cb66781c8ac72a55fff1436e8fc8170a2ce8509.diff"
    FILENAME "range-v3-fork_base_to_2cb66781c8ac72a55fff1436e8fc8170a2ce8509.diff"
    SHA512 5c1728387967a5c14596d6d71e7c28f0206c22b652f4c96955711bcb805816eb106b62fcfde0a7d514eeed28fe6ce1f8c593fa3ef7df70f8da3b88b6d79c1515
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH} PATCHES ${DIFF})

file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/range-v3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/range-v3/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/range-v3/copyright)
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")
vcpkg_copy_pdbs()
