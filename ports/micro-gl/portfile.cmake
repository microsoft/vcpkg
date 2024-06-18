vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO micro-gl/micro-gl
    REF 1c1dafeccb1b92467d3fd82de00e022a318c8ce8
    SHA512 0
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/micro-gl" DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL "${SOURCE_PATH}/LICENSE.MD" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)