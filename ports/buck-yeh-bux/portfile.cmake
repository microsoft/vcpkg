vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux
    REF 8788509f0281e9a2af34c0399a45a5c9e66a4664 # v1.6.3
    SHA512 a7045a93d91e497ca2b60965bb2f098eae714d00feef0d252747178739cdd981f44cb8983278c679761f61e037da05889f22fa161d26fca05af511fc56c1ac8f
    HEAD_REF main
	PATCHES fix-errorC7595.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
