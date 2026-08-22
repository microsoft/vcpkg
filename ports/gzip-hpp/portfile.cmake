# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/gzip-hpp
    REF v0.1.0 
    SHA512 4f332f08e842583b421932f14ee736a64d090ac22fd4e4654e5d84667c2fd6dcd73206b27b7c0c4f364104af7f4a5ad765c38125574bc239fa93b0b0ec4dad56
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/gzip DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)