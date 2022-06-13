vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO DragonJoker/RenderGraph
    REF 13a196fc91df174290c88b2d3ddca93974abd004
    HEAD_REF master
    SHA512 cd3b2ce33d799488ce5beacad37ef36bcbe8e597e39f5656e1e54c7c1c634b77e1ce43b64ea6598beb942d78afb1a4ca286bcc7052dac0ba62385fe274ae4393
)

vcpkg_from_github(OUT_SOURCE_PATH CMAKE_SOURCE_PATH
    REPO DragonJoker/CMakeUtils
    REF 9fbaae40ccdc92f86989dc6875f362e7943b6a94
    HEAD_REF master
    SHA512 dada8ac1f9676c60f1ff5a09a9f788eb8d85eaca450407e4bf0100fbec87228f99cf66cb23de9c9358dda72c426655814cbd1ea90360ca0c63e7660c15aff22b
)

get_filename_component(SRC_PATH "${CMAKE_SOURCE_PATH}" DIRECTORY)
if (EXISTS "${SRC_PATH}/CMake")
    file(REMOVE_RECURSE "${SRC_PATH}/CMake")
endif()
file(RENAME "${CMAKE_SOURCE_PATH}" "${SRC_PATH}/CMake")
set(CMAKE_SOURCE_PATH "${SRC_PATH}/CMake")
file(COPY "${CMAKE_SOURCE_PATH}" DESTINATION "${SOURCE_PATH}")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DPROJECTS_USE_PRECOMPILED_HEADERS=ON
        -DCRG_UNITY_BUILD=ON 
        -DCRG_BUILD_STATIC=${BUILD_STATIC}
        -DVULKAN_HEADERS_INCLUDE_DIRS=${CURRENT_INSTALLED_DIR}/include
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/RenderGraph)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)