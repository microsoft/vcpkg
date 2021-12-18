vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO freeglut/freeglut
    REF 3.2.1
    FILENAME "freeglut-3.2.1.tar.gz"
    SHA512 aced4bbcd36269ce6f4ee1982e0f9e3fffbf18c94f785d3215ac9f4809b992e166c7ada496ed6174e13d77c0f7ef3ca4c57d8a282e96cbbe6ff086339ade3b08
    PATCHES 
        use_targets_to_export_x11_dependency.patch
        macOS_Xquartz.patch
        gcc10.patch
        fix-debug-macro.patch
        no_x64_enforcement.patch
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
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
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/FreeGLUT)

# Rename static lib (otherwise it's incompatible with FindGLUT.cmake)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
            file(RENAME ${CURRENT_PACKAGES_DIR}/lib/freeglut_static.lib ${CURRENT_PACKAGES_DIR}/lib/freeglut.lib)
        endif()
        if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
            file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/freeglut_staticd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/freeglutd.lib)
        endif()
    endif()

    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/GL/freeglut_std.h"
        "ifdef FREEGLUT_STATIC"
        "if 1 //ifdef FREEGLUT_STATIC"
    )
endif()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/glut)
endif()

vcpkg_fixup_pkgconfig()
