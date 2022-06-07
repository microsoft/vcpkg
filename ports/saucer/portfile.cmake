vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO saucer/saucer
    REF 38a216ecf4dc4d961dc466b83e50619651351ba4
    SHA512 419371ba1d64bd97f3fcc4974d8d99ab9bd769aec95e02df4a576b59e611576a9c02040e708165e8336201fb1289413c0d8dedfd7683949a8cf41489864625de
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH} 
    OPTIONS -Dsaucer_prefer_remote=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
