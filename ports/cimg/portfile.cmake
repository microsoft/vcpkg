set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO GreycLab/CImg
    # Using commit id becuase upstream likes to change tags
    REF 7d168a8a013ded3c6d5ab7a0a50ec38b3e3d7790
    SHA512 4c009c29cfa8401ba4249428e92eb82b085d70471bdd3745cf4ffa5aeac0cca7a9f2c902df966b17e3e8223bed3591ea6ab485cb455019d4f05b39671b920da6
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/Licence_CeCILL-C_V1-en.txt"
        "${SOURCE_PATH}/Licence_CeCILL_V2-en.txt"
)
