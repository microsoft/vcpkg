# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_colony
    REF e6e563b63dd9e64fc2fcc66a757e366641e62f01
    SHA512 61723a47387fb3ce9a342fbd6db11369774c1a5c5d28ba2db1fee3396a0588a0e9df50cbcaa4561f409d34ddadc17ae61dba29606aa6481647f3bcd003cfaafa
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/plf_colony.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
