set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO GreycLab/CImg
    # Using commit id becuase upstream likes to change tags
    REF a5fb0fd2efff9af9c7482a2c064f82b8da7c3ceb
    SHA512 c15ccab40400c8b00e8899a08c67cc5f867db1fd01222e420cb2a7f8b3f5cd625573900d8c192e22156e11930953c6e6676d83a97734cd4f1bd46fea47d7d735
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
