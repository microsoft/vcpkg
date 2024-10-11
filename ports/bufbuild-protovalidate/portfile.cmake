vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bufbuild/protovalidate
    REF v${VERSION}
    SHA512 dfadb13999b43f4cc091e515c2915dcbca22cffa56a5091017df3eb578bda17ee03d1631997f66c66a2d2cc6893bfae851871a3a628c44a0385bfcaf66c15fa3
    HEAD_REF main
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/proto/protovalidate")

find_program(BUF_EXECUTABLE NAMES buf PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/buf" NO_DEFAULT_PATH REQUIRED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/proto/protovalidate"
    OPTIONS
        -DBUF_EXECUTABLE=${BUF_EXECUTABLE}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
