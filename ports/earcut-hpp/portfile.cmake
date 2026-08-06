vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/earcut.hpp
    REF "v${VERSION}"
    SHA512 15f5ea72bddf63549bc7a178009ccc949bf078f45f527bd9d41d4e40b5972e09f5c61dd25375bf12dd7a623f9ad0df556733aa1492153c214715ad4319cb21ed
    HEAD_REF master
)

# This is a header only library
file(INSTALL "${SOURCE_PATH}/include/mapbox/earcut.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mapbox")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
