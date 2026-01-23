vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bitfactory-software/anyxx
    REF "04668bd1874a0adf555c8674571a29f0cbef131b"
    SHA512 66009802fae4f10c0fc043d92f244a257881a26aa53df57c85890ea03ead81994c3dde39cde9a11906a1529018b826b9cb1a92c4be2d6acab67d4924a60347c2
    HEAD_REF master
)

# This is a header only library
file(INSTALL "${SOURCE_PATH}/bit_factory/anyxx.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/bit_factory")

# Supply usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

# Install the wrapper so find_package() works
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")