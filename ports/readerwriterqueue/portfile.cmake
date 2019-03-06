# header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cameron314/readerwriterqueue
    REF v1.0.1
    SHA512 cb1cc0add78ec6994799c5b3406d310bfcdad74756a6995404d9ea659b7fc6cb7f2b3667c2e3fc0cfcb7ad9c376744c6a3988cb9cc4e0ae0d59ff5dd818d7f11
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/readerwriterqueue RENAME copyright)

file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/readerwriterqueue)
