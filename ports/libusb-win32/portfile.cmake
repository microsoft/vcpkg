include(vcpkg_common_functions)

if (VCPKG_CMAKE_SYSTEM_NAME)
    message(FATAL_ERROR "Error: only Windows Desktop builds are currently supported.")
endif()

set(LIBUSB_VERSION 1.2.6.0)
set(LIBUSB_HASH 972438b7465a22882bc91a1238291240ee3cdb09f374454a027d003b150656d4c262553104f74418bb49b4a7ca2f1a4f72d20e689fa3a7728881bafc876267f4)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libusb-win32-src-${LIBUSB_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/libusb-win32/files/libusb-win32-releases/${LIBUSB_VERSION}/libusb-win32-src-${LIBUSB_VERSION}.zip/download"
    FILENAME "libusb-win32-${LIBUSB_VERSION}.zip"
    SHA512 ${LIBUSB_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYING_LGPL.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/libusb-win32)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libusb-win32/COPYING_LGPL.txt ${CURRENT_PACKAGES_DIR}/share/libusb-win32/copyright)
