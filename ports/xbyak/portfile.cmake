vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO herumi/xbyak
    REF v5.93
    SHA512 0c7052b2aeffc1aec541991a644753327232428ba7d8719e250a3afcc66b26beca2b92476f17af8121ceaacd822515e65d082e94b9f72fa29b4a005e32065843
    HEAD_REF master
)

# handle license file
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# copy headers
file(GLOB HEADER_FILES ${SOURCE_PATH}/xbyak/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/xbyak)
