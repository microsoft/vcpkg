set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO GreycLab/CImg
    # Using commit id becuase upstream likes to change tags
    REF 1a9fef439d17b73d9af8d8e59b65df9c989fde7a
    SHA512 fbb7ff967b59cd24e85602ae1b6278cda857ebb22679593695809d10c7e211716426f7529d6d4edd6983770673529946e69613e989b24609e029fa863915da5b
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(
    COMMENT "Upstream does not bundle the CeCILL 2.1 agreement; plugins/inpaint.h contains the same dual-license notice as CImg.h. plugins/matlab.h does not specify an LGPL version; the manifest represents this notice as LicenseRef-LGPL."
    FILE_LIST
        "${SOURCE_PATH}/Licence_CeCILL-C_V1-en.txt"
        "${SOURCE_PATH}/Licence_CeCILL_V2-en.txt"
        "${SOURCE_PATH}/plugins/inpaint.h"
        "${SOURCE_PATH}/plugins/matlab.h"
)
