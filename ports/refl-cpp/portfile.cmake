# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO veselink1/refl-cpp
    REF v0.12.0
    SHA512 e9103ac491cc2d06cd5223a55094473f479eabd49c733d2d4a11e560f3063474e34785e2681a4c5fcec3f2912c3cccefca7fa1c40bd95fd01f4d40df6c322648
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/refl.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
