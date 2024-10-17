vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erincatto/Box2D
    REF v3.0.0
    SHA512 b56e4e79aa3660ee728c1698b7a5256727b505d993103ad3cc6555e9b38cf81e6f26d5cbc717bdc6f386a6062ee47065277778ca6dd78cacb35f2d5e8c897723
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DPROJECT_IS_TOP_LEVEL=OFF
        -DBOX2D_PROFILE=OFF
        -DBOX2D_UNIT_TESTS=OFF
        -DBOX2D_SAMPLES=OFF
)
vcpkg_cmake_install()

file(GLOB_RECURSE HEADER_FILES "${SOURCE_PATH}/include/*.h")
file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/box2d")

set(CMAKE_CONFIG_DIR "${CURRENT_PACKAGES_DIR}/lib/cmake/box2d")
file(MAKE_DIRECTORY "${CMAKE_CONFIG_DIR}")

set(DEBUG_CONFIG_DIR "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/box2d")
file(MAKE_DIRECTORY "${DEBUG_CONFIG_DIR}")

set(CONFIG_FILES_DIR "${CMAKE_CURRENT_LIST_DIR}/config")

file(COPY "${CONFIG_FILES_DIR}/box2dConfig.cmake" DESTINATION "${CMAKE_CONFIG_DIR}")
file(COPY "${CONFIG_FILES_DIR}/box2dConfig-release.cmake" DESTINATION "${CMAKE_CONFIG_DIR}")
file(COPY "${CONFIG_FILES_DIR}/box2dConfigVersion.cmake" DESTINATION "${CMAKE_CONFIG_DIR}")

file(COPY "${CONFIG_FILES_DIR}/box2dConfig.cmake" DESTINATION "${DEBUG_CONFIG_DIR}")
file(COPY "${CONFIG_FILES_DIR}/box2dConfig-debug.cmake" DESTINATION "${DEBUG_CONFIG_DIR}")
file(COPY "${CONFIG_FILES_DIR}/box2dConfigVersion.cmake" DESTINATION "${DEBUG_CONFIG_DIR}")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/box2d)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_copy_pdbs()

#file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
