vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO memononen/nanovg
    REF ce3bf745eb2d2dbc14a50bf2446783f691ac4353
    SHA512 1eae11ec484fb184a3497ba7a7b84e9d298c9bef5353c1d13691660e848f218b5e3e3d2259c83d8475196c791e7433aed302931799bc0f5f3c4666b3b07236d3
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/nanovgConfig.cmake" DESTINATION "${SOURCE_PATH}")

file(GLOB STB_SRCS "${SOURCE_PATH}/src/stb_*")
if(STB_SRCS)
    file(REMOVE_RECURSE ${STB_SRCS})
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/nanovg)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
