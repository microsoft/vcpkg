set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO dtschump/CImg
    REF "v.${VERSION}"
    SHA512 54357c177c1e25117778d444e0317a5a5f9dc9dd40ff2c280b6c05f846b2352c523ba6ab9eeea2e05094cc8fbbfe5a544a5f83eeda46394b3d87962b3b1e31d5
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
