include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "https://github.com/glfw/glfw/releases/download/3.1.2/glfw-3.1.2.zip"
    FILENAME "glfw-3.1.2.zip"
    SHA512 c199137b32182182123869fe69ab991a296feb80dcf3db3cf5e070cdaef31ed958148d9b87e724c1937fa535960122bdceb92ea9dd38f7ef41e4e08e36210fe5
)
vcpkg_extract_source_archive(${ARCHIVE})

if(NOT EXISTS ${CURRENT_BUILDTREES_DIR}/patch.stamp)
    file(READ ${CURRENT_BUILDTREES_DIR}/src/glfw-3.1.2/src/glfw3Config.cmake.in CONFIG)
    string(REPLACE "\"@GLFW_LIB_NAME@\"" "NAMES @GLFW_LIB_NAME@ @GLFW_LIB_NAME@dll"
        CONFIG ${CONFIG}
    )
    string(REPLACE "@PACKAGE_CMAKE_INSTALL_PREFIX@" "@PACKAGE_CMAKE_INSTALL_PREFIX@/../.."
        CONFIG ${CONFIG}
    )
    file(WRITE ${CURRENT_BUILDTREES_DIR}/src/glfw-3.1.2/src/glfw3Config.cmake.in ${CONFIG})
    file(APPEND ${CURRENT_BUILDTREES_DIR}/src/glfw-3.1.2/src/glfw3Config.cmake.in "set(GLFW3_LIBRARIES \${GLFW3_LIBRARY})\n")
    file(WRITE ${CURRENT_BUILDTREES_DIR}/patch.stamp)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/glfw-3.1.2
    OPTIONS
        -DBUILD_SHARED_LIBS=ON
        -DGLFW_BUILD_EXAMPLES=OFF
        -DGLFW_BUILD_TESTS=OFF
        -DGLFW_BUILD_DOCS=OFF
        -DPACKAGE_CMAKE_INSTALL_PREFIX=\${CMAKE_CURRENT_LIST_DIR}/../..
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/share
)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/glfw3.dll ${CURRENT_PACKAGES_DIR}/bin/glfw3.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/glfw3.dll ${CURRENT_PACKAGES_DIR}/debug/bin/glfw3.dll)

file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/glfw ${CURRENT_PACKAGES_DIR}/share/glfw3)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/glfw/glfwTargets-debug.cmake ${CURRENT_PACKAGES_DIR}/share/glfw3/glfwTargets-debug.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/glfw3.lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/glfw3.lib)

file(COPY ${CURRENT_BUILDTREES_DIR}/src/glfw-3.1.2/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/glfw3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glfw3/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/glfw3/copyright)
vcpkg_copy_pdbs()

