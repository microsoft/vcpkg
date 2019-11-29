# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO silentbicycle/greatest
    REF v1.4.2
    SHA512 8f2767ac2be017d2ecee3a903ab79834e783df464e3fd0e1e8c4397fdf8dabcc4fb2367163dcb9e944c404d00cf8960ec56c0345f43836182a6e058d9eaf6b0a
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/greatest.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
