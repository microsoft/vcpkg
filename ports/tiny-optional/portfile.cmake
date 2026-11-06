set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Sedeniono/tiny-optional
    REF "v${VERSION}"
    SHA512 9457f6d67216c3b12ef5caec7540c9f92ce0a039f21bc81a2b640d9919a8da37fb90647d1bf52aa0adb5f28b65a7766ac8aa6594458566a5d3ae9fc77e8328f8
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
