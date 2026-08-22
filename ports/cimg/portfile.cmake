set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO GreycLab/CImg
    # Using commit id becuase upstream likes to change tags
    REF ed8d53c7f2469c8b8e23c11cb880f42f6cb74ab9
    SHA512 10a44ad2d8a1a93bcd38501be9cfad3840675653abfefb2c539c098653179e77cdd34aa323ae28958522dfaddee376c5cf04d6871cc600398738b98a272f320c
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
