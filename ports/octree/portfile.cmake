vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "SpiriMirror/Octree"
    REF "${VERSION}"
    SHA512 56d10d535c0b427cffdddaf5a17047b3beb63296ed2a587973a6b017e5248b0b3b89ba0e4a5f84cfc9ce3de3ce01e7dcacece99e246bf7247649c87a071cf755
    HEAD_REF mini20
)

# set(SOURCE_PATH "/Users/luxinyu/Projects/SpiriVcpkg/Octree")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
