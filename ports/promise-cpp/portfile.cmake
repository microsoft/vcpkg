vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xhawk18/promise-cpp
    REF 2.1.2
    SHA512 490571e6d6742e05ae6a2549af4e242a1d7084edc583fbbb183798bdddb25d08a7f68becfa94f55b877cba7e2e8e8515964f892881591b5bb394b4b33e6593f7
    HEAD_REF master
    PATCHES fix-ifdef.patch
)

file(GLOB PROMISE_HEADERS "${SOURCE_PATH}/include/*.hpp")
file(INSTALL "${SOURCE_PATH}/include/promise-cpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
