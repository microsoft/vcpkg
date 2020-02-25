# header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cameron314/readerwriterqueue
    REF 265ec3ca37fd530f4d042bc8a23c03382b0f954c # v1.0.2
    SHA512 3fdeb0778fdb949b4110b6c829394e566eb24e07520df82a5d160a697b35d3e3da2daa09b7d239c1d1ffe471e60aaade9e3e2ce5ecc0a84f3fb4d2fc60d05c58
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/readerwriterqueue RENAME copyright)

file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/readerwriterqueue)
