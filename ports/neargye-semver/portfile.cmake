# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/semver
    REF v0.3.0
    SHA512 b620a27d31ca2361e243e4def890ddfc4dfb65a507187c918fabc332d48c420fb10b0e6fb38c83c4c3998a047201e81b70a164c66675351cf4ff9475defc6287
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/semver.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/neargye")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
