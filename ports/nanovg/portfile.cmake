vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO memononen/nanovg
    REF 1f9c8864fc556a1be4d4bf1d6bfe20cde25734b4
    SHA512 99a44f01114ee653a966d4695596886240752f5a06d540c408b5aeaebdcc5360fc2043276515695580d048649a20dc50409107f89c4ce506d2ccb83a0635d29f
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/nanovgConfig.cmake DESTINATION ${SOURCE_PATH})

file(GLOB STB_SRCS ${SOURCE_PATH}/src/stb_*)
if(STB_SRCS)
    file(REMOVE_RECURSE ${STB_SRCS})
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
