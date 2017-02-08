#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cereal-1.2.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/USCiLab/cereal/archive/v1.2.1.tar.gz"
    FILENAME "cereal-1.2.1.tar.gz"
    SHA512 f0050f27433a4b544e7785aa94fc7b14a57eed6d542e25d3d0fda4d27cf55ea55e796be2138bf80809c96c392436513fe42764b3a456938395bf7f7177dd1c73
)
vcpkg_extract_source_archive(${ARCHIVE})

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cereal)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cereal/LICENSE ${CURRENT_PACKAGES_DIR}/share/cereal/copyright)

# Copy the cereal header files
file(COPY ${SOURCE_PATH}/include/cereal DESTINATION ${CURRENT_PACKAGES_DIR}/include)