# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO veselink1/refl-cpp
    REF v0.9.1
    SHA512 ddb48d7f75cf7757031af28b53d07a104cb64e279c8fc23575639c3839f1501b346e40963d358629b612e4f64aba6f86ffc5a592dd6cd8febf872a8cd1466171
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/refl.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
