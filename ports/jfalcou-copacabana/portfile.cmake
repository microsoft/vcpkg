# Copacabana is a tree of CMake scripts, included by path rather than found by
# find_package. It is consumed at configure time through CPM_COPACABANA_SOURCE.
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/copacabana
    REF "v${VERSION}"
    SHA512 805dcf9b799ea496f7897910d55731b90ec4a0c937992b5786ee307ed38e47421cf49bc3613f8f42ee6bc453eb50292aae3cb9509da45eb74c02a636a097fb68
    HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/copacabana" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
