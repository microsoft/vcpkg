set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO dtschump/CImg
    REF "v.${VERSION}"
    SHA512 fa3b2038973f027132edb731496f57f9f0b684bb729a9a62e202cd7101a665d25ac2ea8236097b003ae111d12f357e2d4083a6f375b4859f0027841659fd95d5
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
