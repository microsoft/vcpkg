# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF v0.9.4
    SHA512 472f4ce4ff5ba4b2e175120deb0a3ccc4c7b124e9349fd7709e1439fcdcfbc83ff0fb71d58367f38e042c4a64600936755432bd4de3e0065b2810dc5bc7d3c86
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/httplib.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
