vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ladislav-zezula/StormLib
    REF "v${VERSION}"
    SHA512 0da78bda4bb89637da892fc73a0673b8a5f852ede4fdceba1029431d24dd1e59db9bfceafab1c5fb642e4b5d0d15d9865f7a138bfb190ce0c2d3601b22dd3023
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
