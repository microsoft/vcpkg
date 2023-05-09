vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ariya/FastLZ
    REF c3bdfad9e0094d0fb15c12cd300e647c13dc85f9 #2021-5-10
    SHA512 cb1c7e365e955f4cabfcb0bebf9cb57e88e81183fc0bec0713a88acee6bc3aeb31cdf8fa0b56b4b7c63f220ab7b50c299b13df15912a3b4a01ec70dd2a9513f7
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.MIT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
