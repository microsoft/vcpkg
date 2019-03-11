include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mrtazz/restclient-cpp
    REF 0.5.0
    SHA512 ae17cc878b386f5486d0bf841cab2cdd1dcb5b65e0ea8f17d510d3fdf215c1917d37021541726f1c6ab943321d1c3b50934fdceea0824b211fd5928f4861011c
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/restclient-cpp)

# Remove includes in debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/restclient-cpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/restclient-cpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/restclient-cpp/copyright)

# Copy pdb files
vcpkg_copy_pdbs()