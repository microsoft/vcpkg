# Header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SergiusTheBest/plog
    REF 1.1.4
    SHA512 7af75af8343460d62e04cc0c27d4cf86373b136df73d2312d19a2e57fa309e916cef8625b8eed1b7270b93aa5d1ff27aee6edb74beb138e3a21c06a3c3debb41
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/plog)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/plog/LICENSE ${CURRENT_PACKAGES_DIR}/share/plog/copyright)

# Copy header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.h")
