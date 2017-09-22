# Header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SergiusTheBest/plog
    REF 1.1.3
    SHA512 9a5a455e1942158d2802313682ed007750789a9048773302d92f2591dfac0185914dba8b67fa285fed25e54dff44e2c97c92b9e7decd39fa2bca460c03549377
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/plog)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/plog/LICENSE ${CURRENT_PACKAGES_DIR}/share/plog/copyright)

# Copy header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.h")
