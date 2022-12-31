vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/earcut.hpp
    REF v2.2.3
    SHA512 f87f0084dbbcda85b409c326587a376d443f2484b6a69c216d2ad94ea8ea238912dfe1174b464b08faec10ea5c29ebae6478e7abfe5ff682a7b043784c1e3acf
    HEAD_REF master
)

# This is a header only library
file(INSTALL "${SOURCE_PATH}/include/mapbox/earcut.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mapbox")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
