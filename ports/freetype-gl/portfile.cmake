if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rougier/freetype-gl
    REF 82fb152a74f01b1483ac80d15935fbdfaf3ed836
    SHA512 4842d9e66fd25dbb3a4e3f4bf597a0c1fc3c3c30e0cb1baae1c3306ddcb663ff9108d8fc01bde539fea7cb03a6329054f66166d9e448086358ab7b05953f5884
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-Use-external-Glew-and-Freetype.patch"
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
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/Release/*.lib"
)
file(GLOB DEBUG_LIBS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*/Debug/*.lib"
)
file(INSTALL ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/freetype-gl RENAME copyright)
