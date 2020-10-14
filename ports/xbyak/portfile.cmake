vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO herumi/xbyak
    REF v5.97
    SHA512 813d5363063b9bd8f3645652826cbbf9c0fdfc7775974bd257b9635ce7d1edbd6a7099216a8e7ec6252cb6e56aa4b6c6f9b0fd84b5748fa79c04abb799731cde
    HEAD_REF master
)

# handle license file
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# copy headers
file(GLOB HEADER_FILES ${SOURCE_PATH}/xbyak/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/xbyak)
