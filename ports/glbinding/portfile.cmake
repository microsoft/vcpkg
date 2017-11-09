# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cginternals/glbinding
    REF v2.1.1
    SHA512 6c7251555801272a90c87a9386324eb6993102601a036fc7d9f9b4ebed64c74d011909566e5fc5a34ef8242e24915848296023daa1420c91aaf08cf9635be397
    HEAD_REF master
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DOPTION_BUILD_TESTS=OFF
        -DOPTION_BUILD_GPU_TESTS=OFF
)

#vcpkg_build_cmake()
vcpkg_install_cmake()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/glbinding ${CURRENT_PACKAGES_DIR}/share/glbinding)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)

file(READ ${CURRENT_PACKAGES_DIR}/debug/cmake/glbinding/glbinding-export-debug.cmake GLBINDING_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" GLBINDING_DEBUG_MODULE "${GLBINDING_DEBUG_MODULE}")
string(REPLACE "glbindingd.dll" "bin/glbindingd.dll" GLBINDING_DEBUG_MODULE "${GLBINDING_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/glbinding/glbinding-export-debug.cmake "${GLBINDING_DEBUG_MODULE}")
file(READ ${CURRENT_PACKAGES_DIR}/share/glbinding/glbinding-export-release.cmake RELEASE_CONF)
string(REPLACE "glbinding.dll" "bin/glbinding.dll" RELEASE_CONF "${RELEASE_CONF}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/glbinding/glbinding-export-release.cmake "${RELEASE_CONF}")
file(REMOVE ${CURRENT_PACKAGES_DIR}/glbinding-config.cmake)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/glbinding-config.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glbinding/glbinding-export.cmake ${CURRENT_PACKAGES_DIR}/share/glbinding/glbinding-config.cmake)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/glbinding.dll ${CURRENT_PACKAGES_DIR}/bin/glbinding.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/glbindingd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/glbindingd.dll)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/data ${CURRENT_PACKAGES_DIR}/share/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/data)
file(REMOVE ${CURRENT_PACKAGES_DIR}/AUTHORS
            ${CURRENT_PACKAGES_DIR}/LICENSE
            ${CURRENT_PACKAGES_DIR}/README.md
            ${CURRENT_PACKAGES_DIR}/VERSION
            ${CURRENT_PACKAGES_DIR}/debug/AUTHORS
            ${CURRENT_PACKAGES_DIR}/debug/LICENSE
            ${CURRENT_PACKAGES_DIR}/debug/README.md
            ${CURRENT_PACKAGES_DIR}/debug/VERSION
    )

# There are some executables that are only built if glfw is found by CMake (see source/tools/*/CMakeLists.txt).
# glfw is not listed as a dependency for glbinding, so this only happen on systems where package glfw3 is present.
# glbinding's CMake doesn't offer the choice to exlude those tools from the build process, so deleting them here:
file(REMOVE ${CURRENT_PACKAGES_DIR}/glcontexts.exe
            ${CURRENT_PACKAGES_DIR}/glfunctions.exe
            ${CURRENT_PACKAGES_DIR}/glmeta.exe
            ${CURRENT_PACKAGES_DIR}/glqueries.exe
            ${CURRENT_PACKAGES_DIR}/debug/glcontextsd.exe
            ${CURRENT_PACKAGES_DIR}/debug/glfunctionsd.exe
            ${CURRENT_PACKAGES_DIR}/debug/glmetad.exe
            ${CURRENT_PACKAGES_DIR}/debug/glqueriesd.exe
)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/glbinding)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glbinding/LICENSE ${CURRENT_PACKAGES_DIR}/share/glbinding/copyright)

vcpkg_copy_pdbs()