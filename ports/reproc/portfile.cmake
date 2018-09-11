include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF fbc9b35e7621f210829109c4470b43d10768af5a
    SHA512 2a0b91fa17c6df1a1ef95f94b4aebba7cd5c3093c083b37593819c6ce9a91713453d69185a95e0a3187c0ad68a8b48a208c78bf9dcc9f99972e830dd25e40666
    HEAD_REF master
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS 
		-DREPROC_BUILD_CXX_WRAPPER=ON
		-DREPROC_INSTALL=ON
)

vcpkg_install_cmake()

# Debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# CMake Files
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/reproc/cmake)

file(GLOB DEBUG_CMAKE_FILES "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/reproc/*")
file(COPY ${DEBUG_CMAKE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/reproc/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

file(GLOB RELEASE_CMAKE_FILES "${CURRENT_PACKAGES_DIR}/lib/cmake/reproc/*")
file(COPY ${RELEASE_CMAKE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/reproc/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)

# Handle License
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/reproc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/reproc/LICENSE ${CURRENT_PACKAGES_DIR}/share/reproc/copyright)