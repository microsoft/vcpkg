set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO GreycLab/CImg
    # Using commit id becuase upstream likes to change tags
    REF cfe2bf3d022b0bb0bc6944dcad6e606286084423
    SHA512 9fcad36f6adebabcf69f453c196a60e8a61a3cacc0362d7dce4ecfe9f27d2e30dc032944c048121d4e32dd785947fb5c669a21025b6fef8b7f2230791bb831c1
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
