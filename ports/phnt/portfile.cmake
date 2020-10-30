#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO processhacker/phnt
    REF 33cfd75a2be59bbde3aa4db3399a9e6bab66ae6a
    SHA512 90a1b38d27e35e7706e66dae0f4e151b50f5b74fbedf15ad165beece6a94b8a87263e16e1e0b891a324091c3769fd2ff2f541e11691b322413e575e6f08dc746
    HEAD_REF master
)

# Install headers
file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/phnt RENAME copyright)