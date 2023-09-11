vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alugowski/task-thread-pool
    REF v${VERSION}
    SHA512 8f67e4d467c16bd0986f4fbfda6e7ca74760ddf3c4333660c764c97df0a21a40f36dc5af11c47f41e1cc0eb9c498ff2ca7b93a11a32dea296181592f5a05fd1d
    HEAD_REF main
)

file(GLOB HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/include/*.hpp")

file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-BSD.txt" "${SOURCE_PATH}/LICENSE-Boost.txt" "${SOURCE_PATH}/LICENSE-MIT.txt")
