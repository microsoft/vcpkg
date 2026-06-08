vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mcuee/libusb-win32
    REF "release_${VERSION}"
    SHA512 a3beebf7931bf94e896973994e77e5a3b2e1c7a3077c677fe3f9641138ae4bfe44a79b8be5838cdaf5e12ad143096a6e36c3969e4649bd7c5b0783771a3c3e80
    HEAD_REF master
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/libusb")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}/libusb")
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/libusb/COPYING_LGPL.txt")
