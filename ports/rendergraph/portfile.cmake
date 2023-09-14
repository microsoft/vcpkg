vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO DragonJoker/RenderGraph
    REF v${VERSION}
    HEAD_REF master
    SHA512 48bb3211022499538eebca0051f931ec105af9ccd3fea21d546fcd9cb41bc9d2191c70382e00caaf79fce48303e56d83d7089f7b975f635bcef3645c80abda30
)

vcpkg_from_github(OUT_SOURCE_PATH CMAKE_SOURCE_PATH
    REPO DragonJoker/CMakeUtils
    REF 7d355194fa795c437ce970cecf00e23ae10fc686
    HEAD_REF master
    SHA512 ca25b19bdeb3e8fda7abc32f8548731f0ba1cd09889a70f6f287ad76d2fdfa0fedbb7f6f65b26d356ea51543bed8926c6bb463f8e8461b7d51d3b7b33134374c
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

vcpkg_copy_pdbs()
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/RenderGraph)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
