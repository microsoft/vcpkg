set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

message(STATUS "\nPlease use the following command when you need to remove all boost ports/components:\n\
    \"./vcpkg remove boost-uninstall:${TARGET_TRIPLET} --recurse\"\n")

vcpkg_download_distfile(
    FILE_PATH
    URLS https://gitlab.kitware.com/cmake/cmake/-/raw/v3.24.3/Modules/FindBoost.cmake
    FILENAME FindBoost-CMake-3.24.3.cmake
    SHA512 db16fa222ec28135d6dd13d62661d01850f93d68b3cbc5d035da92e6c4337285676885b9d27bc7f0dda7dd620de6536c804ef760f78b3959cd5d1d50cc27a7df
)

file(INSTALL "${FILE_PATH}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/boost" RENAME "FindBoost.cmake")

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/boost/vcpkg-cmake-wrapper.cmake" @ONLY)
