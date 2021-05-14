# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LukasBanana/GaussianLib
    REF 8630d4ac14a37f01c71bdf0c1c653e3746aa08da
    SHA512 70de394496f20fe7037782d16cfa4bcd85beefdb25094247b8b572e6bb55866be6e2c82722d705141919b91f24428dde7b32f3d8a39670e7ef324c81b1ebe7e2
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/Gauss DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
