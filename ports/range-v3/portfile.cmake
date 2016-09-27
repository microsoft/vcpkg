include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/Range-V3-VS2015/archive/ede9ad367fd5ec764fecb039c874614bd908e6b6.zip"
    FILENAME "range-v3-ede9ad367fd5ec764fecb039c874614bd908e6b6.zip"
    SHA512 e978c7694471d8616c248647b77689f377b3e2517347abde8629b140e5994de8bf686565a24cdd7dd222f325d43b775f5e478c91220dce75313985499b134637
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CURRENT_BUILDTREES_DIR}/src/Range-V3-VS2015-ede9ad367fd5ec764fecb039c874614bd908e6b6/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/range-v3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/range-v3/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/range-v3/copyright)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/Range-V3-VS2015-ede9ad367fd5ec764fecb039c874614bd908e6b6/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")
vcpkg_copy_pdbs()
