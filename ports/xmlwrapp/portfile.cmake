# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/xmlwrapp-0.9.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/vslavik/xmlwrapp/archive/v0.9.0.zip"
    FILENAME "v0.9.0.zip"
    SHA512 04660e1eb92423ba7419ae36969cb5d77a0b01ab8e627a73d2c5aeb70d9a21e6578c9befa26fbbb857599f0d73e97768afbc9e652e7febd5eeaae97cc2fd74ac
)
vcpkg_extract_source_archive(${ARCHIVE})

#Move the export.h file out of the way for now as it is only appropriate for creating static libraries. The 
#CMakeLists_xmlwrapp.txt file will copy an appropriate one (i.e static or dll version) to the cmake bin directory.
if (${SOURCE_PATH}/include/xmlwrapp/export.h)
    file(RENAME ${SOURCE_PATH}/include/xmlwrapp/export.h ${SOURCE_PATH}/include/xmlwrapp/export_static.h)
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists_top.txt DESTINATION ${SOURCE_PATH})
file(RENAME ${SOURCE_PATH}/CMakeLists_top.txt ${SOURCE_PATH}/CMakeLists.txt)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists_xmlwrapp.txt DESTINATION ${SOURCE_PATH}/src/libxml)
file(RENAME ${SOURCE_PATH}/src/libxml/CMakeLists_xmlwrapp.txt ${SOURCE_PATH}/src/libxml/CMakeLists.txt)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists_xsltwrapp.txt DESTINATION ${SOURCE_PATH}/src/libxslt)
file(RENAME ${SOURCE_PATH}/src/libxslt/CMakeLists_xsltwrapp.txt ${SOURCE_PATH}/src/libxslt/CMakeLists.txt)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
 #   PREFER_NINJA
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xmlwrapp RENAME copyright)
