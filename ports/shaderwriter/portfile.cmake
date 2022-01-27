vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO DragonJoker/ShaderWriter
    REF ca0e47f57c1984884f0dc62dbfb6ca0eb2e86cb4
    HEAD_REF master
    SHA512 c9b5fdeccbec00a1ab814f37fb5d7a0009faf22884e61b034c625537f9f73a118ff1c3da70721e6d50f861300d71e408ce7a162787d91ba45636783c268da586
)

vcpkg_from_github(OUT_SOURCE_PATH CMAKE_SOURCE_PATH
    REPO DragonJoker/CMakeUtils
    REF 27747f5c91acf76107220986f114efdab0a09a68
    HEAD_REF master
    SHA512 acd5dafc74e197886a9b1ac52b59bdbf2d136cc8b49683eda48b8ccc45eced5f68aa334c8f9c01c7d8bf5c8908b64cbf19a97c6e3666370111bb3d2551c3b469
)

get_filename_component(SRC_PATH ${CMAKE_SOURCE_PATH} DIRECTORY)
if (EXISTS ${SRC_PATH}/CMake)
    file(REMOVE_RECURSE ${SRC_PATH}/CMake)
endif()
file(RENAME ${CMAKE_SOURCE_PATH} ${SRC_PATH}/CMake)
set(CMAKE_SOURCE_PATH ${SRC_PATH}/CMake)
file(COPY ${CMAKE_SOURCE_PATH} DESTINATION ${SOURCE_PATH})

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DPROJECTS_USE_PRECOMPILED_HEADERS=OFF
        -DSDW_GENERATE_SOURCE=OFF
        -DSDW_BUILD_VULKAN_LAYER=OFF
        -DSDW_BUILD_TESTS=OFF
        -DSDW_BUILD_STATIC_SDW=${BUILD_STATIC}
        -DSDW_BUILD_STATIC_SDAST=${BUILD_STATIC}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/shaderwriter)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)