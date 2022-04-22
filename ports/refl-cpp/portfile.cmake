# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO veselink1/refl-cpp
    REF v0.12.2
    SHA512 a124f12f2a491b3f2ea74bcf3b8cd3e14f1a4aa5ede105edbed90c3329af7d7fffa5c7a287f2e1e6079d9f0fad34190887700ae20a7d15f00299526317b41137
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/refl.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
