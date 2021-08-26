vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rougier/freetype-gl
    REF 1a8c007f3fe7b1441f9e5616bc23d7455f4b07dd # accessed on 2020-09-14
    SHA512 ce858b5d5e892162daf6f5bff3476938e15cb9f04adbf2dc2b4c538bfda56b023278b3acb62940a9388c46b89edfd22c9c1c99891f8fcf9d926ffedb8af2b38e
    HEAD_REF master
    PATCHES glew.patch
)

# make sure that no "internal" libraries are used by removing them
file(REMOVE_RECURSE ${SOURCE_PATH}/windows/freetype)
file(REMOVE_RECURSE ${SOURCE_PATH}/windows/AntTweakBar)
file(REMOVE_RECURSE ${SOURCE_PATH}/windows/glew)
file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindGLEW.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dfreetype-gl_BUILD_APIDOC=OFF
        -Dfreetype-gl_BUILD_DEMOS=OFF
        -Dfreetype-gl_BUILD_TESTS=OFF
        -Dfreetype-gl_BUILD_MAKEFONT=OFF
)

# We may soon install using a modified cmake process with install target

# Although FreeType-GL uses CMake as its build system, the implementation
# (*.cmake,CMakeLists.txt) doesn't provide for any type of installation.
# Presumably, it has been used as-is, in-tree, without ever needing to install
# itself within a larger system.
vcpkg_build_cmake(LOGFILE_ROOT install)

file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/freetype-gl)

# LIB
file(GLOB LIBS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/Release/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
)
file(GLOB DEBUG_LIBS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*/Debug/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
)

file(INSTALL ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/freetype-gl RENAME copyright)
