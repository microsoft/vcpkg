include(vcpkg_common_functions)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO dcnieho/FreeGLUT
	REF  3673b101ab751e8b9c55261f32a80b2e4bede242
	SHA512 03834e57bc55dcddceabeaa8fd04db1fd684396b80374c8604a3dd76ef9b4cc84eb15f9ecbacecf1a9e3b779e61fde4ca079d87a89893f7414f00b61c6fd433e 
    HEAD_REF master
    PATCHES 
        use_targets_to_export_x11_dependency.patch
        macOS_Xquartz.patch
        fix-CmakePath.patch
        fix-StaticLib.patch
)

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message("Freeglut currently requires the following libraries from the system package manager:\n    opengl\n    glu\n    libx11\n    xrandr\n    xi\n    xxf86vm\n\nThese can be installed on Ubuntu systems via apt-get install libxi-dev libgl1-mesa-dev libglu1-mesa-dev mesa-common-dev libxrandr-dev libxxf86vm-dev\nOn macOS Xquartz is required.")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(FREEGLUT_STATIC OFF)
    set(FREEGLUT_DYNAMIC ON)
else()
    set(FREEGLUT_STATIC ON)
    set(FREEGLUT_DYNAMIC OFF)
endif()

# Patch header
file(READ ${SOURCE_PATH}/include/GL/freeglut_std.h FREEGLUT_STDH)
string(REGEX REPLACE "\"freeglut_static.lib\""
                     "\"freeglut.lib\"" FREEGLUT_STDH "${FREEGLUT_STDH}")
string(REGEX REPLACE "\"freeglut_staticd.lib\""
                     "\"freeglutd.lib\"" FREEGLUT_STDH "${FREEGLUT_STDH}")
file(WRITE ${SOURCE_PATH}/include/GL/freeglut_std.h "${FREEGLUT_STDH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFREEGLUT_BUILD_STATIC_LIBS=${FREEGLUT_STATIC}
        -DFREEGLUT_BUILD_SHARED_LIBS=${FREEGLUT_DYNAMIC}
        -DFREEGLUT_BUILD_DEMOS=OFF
        -DINSTALL_PDB=OFF # Installing pdbs failed on debug static. So, disable it and let vcpkg_copy_pdbs() do it
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT} ${CURRENT_PACKAGES_DIR}/share/FreeGLUT)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/glut)
endif()
