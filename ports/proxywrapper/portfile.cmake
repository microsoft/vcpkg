vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/proxy-wrapper
    REF b113aa0a284508ce0c2878febf9073d1f03b59dc
    SHA512 9793ec8b9cc0467c88d850ea51a96a0fdc3c3027cc5b7fd9f5d0362d7fd559e909f19a4eaca6554a9316d6e3a86bb5f541034ca9ce2fb8797fb2e5bdff42b0de
    HEAD_REF master
    PATCHES
        fix-find-libproxy.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

