vcpkg_minimum_required(VERSION 2022-10-12)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb-win32/libusb-win32-releases
    REF ${VERSION}
    FILENAME "libusb-win32-src-${VERSION}.zip"
    SHA512 972438b7465a22882bc91a1238291240ee3cdb09f374454a027d003b150656d4c262553104f74418bb49b4a7ca2f1a4f72d20e689fa3a7728881bafc876267f4
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING_LGPL.txt")
