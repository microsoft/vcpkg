set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO GreycLab/CImg
    # Using commit id becuase upstream likes to change tags
    REF 4022e625c5481854070d5f33e940ff623ecfc193
    SHA512 318ce258d75f99d1fe58e46407fde09b83b74ac380ed99eb07422208d6bfe3f59516279b0e889ab17fc53ae5600d753b4e9b4656cab5f623cb97fce085fa0f8c
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(
    COMMENT "plugins/matlab.h does not specify an LGPL version; the manifest represents this notice as LicenseRef-LGPL."
    FILE_LIST
        "${SOURCE_PATH}/Licence_CeCILL-C_V1-en.txt"
        "${SOURCE_PATH}/Licence_CeCILL_V2-en.txt"
        "${SOURCE_PATH}/plugins/matlab.h"
)
