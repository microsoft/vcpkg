# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO veselink1/refl-cpp
    REF v0.12.1
    SHA512 7f1b9473512e305181f2c46940d34aa75a9cee65c69340ddb68b7e5bb2346206ff2c5b83c5d8460bac4a738258e4f6305b6fe8bc3044a1bcb69b30d79dcd5107
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/refl.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
