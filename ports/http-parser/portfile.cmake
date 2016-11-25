# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/http-parser-2.7.1)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/nodejs/http-parser/archive/v2.7.1.zip"
    FILENAME "http-parser-2.7.1.zip"
    SHA512 9fb8b855ba7edb47628c91ac062d7ffce9c4bb8d6b8237d861d7926af989fb3e354c113821bdab1b8ac910f5f1064ca1339947aa20d56f6806b919b0cd6b6eae
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE-MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/http-parser)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/http-parser/LICENSE-MIT ${CURRENT_PACKAGES_DIR}/share/http-parser/copyright)