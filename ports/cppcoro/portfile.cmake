# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lewissbaker/cppcoro
    REF 7ac4be2c0eb825ce4ea92f6496255065ca6fc42f
    SHA512 c516e277341b4473398097b52b15398c4a4de143386eba54e5221ef333c632d1aae2d3a9231cd00df7823b3d4c03f22bfadadb5442af0f5114b18293efa856f6
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/cppcoro DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/cppcoro/copyright COPYONLY)
