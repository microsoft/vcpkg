vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux
    REF b40490e3f386392daff471e420c1cced868ea3b3 # v1.6.7
    SHA512 37b6cedd884f646da1db07c15bb75a357728a30cd93ca945aaa8e0cc3d0e2f7f811468c6d0cba1735badd90c081dc2e5866c74b7410e5d3d417c9fcc62caca02
    HEAD_REF main
    PATCHES fix-clang-cl.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
