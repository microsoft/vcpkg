vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/${PORT}
    REF             c7bdf7ec3c775ad152c845eded85b6b531016993
    SHA512          9876e1c624901474ea26c5ffee8d944062d3d4c097ab4243056530c0ef45c15ec1c6599ed7d058a70e7c460e3416a6aab124560f16f1579d858f7e243e452d7c
    HEAD_REF        cmake
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/cmake/LICENSE.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
