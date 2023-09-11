if(EXISTS ${CURRENT_INSTALLED_DIR}/share/sparsehash/copyright)
    message(FATAL_ERROR "'${PORT}' conflicts with 'sparsehash'. Please remove sparsehash:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sparsehash/sparsehash-c11
    REF "v${VERSION}"
    SHA512 e70f61236f2070da9e5c6a3c3559dee77eb571d996849a5b80fd1c55f7b0b2cae04b59242c103534b897bfe6b542117c252c10ac0a202b5f991ca65e7bad6536
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/sparsehash" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/README" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
