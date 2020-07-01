vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mkazhdan/PoissonRecon
    REF a5c7d359a70c6e560feb5a8543bc38fc71d5a72f
    SHA512 6190666a4f8f3c1b5e3efd0af47af2dbfcff535b3c5a60323301b29b3628d7918a2cb6da1f50e1bb5cf81c3ef1c4db623ef09f4d8d72eae8fb4a1284a55b93d1
    HEAD_REF master
    PATCHES
        use-external-libs.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TOOLS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
