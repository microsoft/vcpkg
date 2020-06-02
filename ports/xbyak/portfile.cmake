vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO herumi/xbyak
    REF v5.911
    SHA512 3cb6b1e73d7dc2a23dcb31310720f0d4b83b62cfc69ff09eeefafe032e58e04574419f668d5ca957e8fc21e679e25da059f6e93724949e0ff1fcaa6779b88bdd
    HEAD_REF master
)

# handle license file
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# copy headers
file(GLOB HEADER_FILES ${SOURCE_PATH}/xbyak/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/xbyak)
