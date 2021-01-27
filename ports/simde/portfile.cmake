# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemequ/simde
    REF f68981de04072012dcc888716dedae2a345d0e45 #v0.7.0
    SHA512 63a00e8a3e0adbd3192f7416f4c163b8b671943042e4f64a91e6865d434a0d5949e97bca1e40d854b9868911ff8d93ac845ac25baa763554447d6be7cdfb084e
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/simde DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
