set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO GreycLab/CImg
    # Using commit id becuase upstream likes to change tags
    REF "v.${VERSION}"
    SHA512 6b4b248e3674b7f9f2b7e39feaa5581b4d1c7c1a4a480245d6f1a858cc36414728ed5ac3484d7bafdbbafae45bf4e0a384251744221b188c025567b908124d44
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
