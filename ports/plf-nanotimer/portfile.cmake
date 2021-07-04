# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_nanotimer
    REF bc8b44d2befc4395f63701c923ece89835d8415c
    SHA512 ec816e82ab855dd7029b03931ffb1e945d3e77f7bb446c4985c4a8404afe20e9de8fac02f64459c47c34e31c06fa8838dba310263197d309e39ec1b0b5da0b6d
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/plf_nanotimer.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
