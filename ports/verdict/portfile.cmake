vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  sandialabs/verdict
    REF ${VERSION}
    SHA512 86a67742f52473c9d51b0259201d47a8f46b7a62d4df11f54e85779c7fc8326e8f7e05a59487070901329f7d191068ecb04e15bd03bd17cc9f5d4977192cf9b3
    HEAD_REF master
    PATCHES include.patch
            fix_osx.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVERDICT_ENABLE_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/verdict" PACKAGE_NAME verdict)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
