if(EXISTS ${CURRENT_INSTALLED_DIR}/share/range-v3/copyright)
    message(FATAL_ERROR "'${PORT}' conflicts with 'range-v3'. Please remove range-v3:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/Range-V3-VS2015
    REF 423bcae5cf18948591361329784d3b12ef41711b
    SHA512 c6756bc6b5131c4c0ffb96550fb40decf734fc8c30e3d51c5c2bf03aae4d7426de36e896a1abf0a200a49a3906d4b60c1cf52f43504554b64d89c91de3e92746
    HEAD_REF master
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(RENAME ${CURRENT_PACKAGES_DIR}/share/range-v3-vs2015/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/range-v3-vs2015/copyright)
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")
vcpkg_copy_pdbs()
