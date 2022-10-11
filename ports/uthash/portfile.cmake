# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO troydhanson/uthash
    REF e493aa90a2833b4655927598f169c31cfcdf7861
    SHA512 a4a2cdee11b238f57bdc3104eee1b3d2014359b65ada896dd26c7f21dda13921f63b44d3d0e7b6fa03731f64b4b4013861d0a49df8b54d7e3726454cbfebaa39
    HEAD_REF master
)

file(GLOB uthash_PUBLIC_HEADERS ${SOURCE_PATH}/src/*.h)
file(INSTALL ${uthash_PUBLIC_HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
