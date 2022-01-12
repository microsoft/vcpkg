vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TartanLlama/ranges
    REF f1aa65d89cee16071f1f5b21e32df5f8ff0d1688
    SHA512 0b94ceba4aaa26a2aefff7837df7b832aea79a5822fb33f18ba47610aed7341ff173b23b8fe9dbf8060c144edd44ae916a3c71db440a66f3c1e8f7bdab27d767
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRANGES_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)