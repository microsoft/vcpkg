vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeGLUTProject/freeglut
    REF "v${VERSION}"
    SHA512 4bb6d6c086bac7a9c0ec78062dce58987555785abe6375f462ee249f65210a964a28fb10ba7ee8a42d7fafb00eb8d196eb403d65d255f02f88467369c187228b
    HEAD_REF master
    PATCHES 
        x11-dependencies-export.patch
        fix-debug-macro.patch
        no_x64_enforcement.patch
        windows-output-name.patch
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    message("Freeglut currently requires the following libraries from the system package manager:\n    opengl\n    glu\n    libx11\n    xrandr\n    xi\n    xxf86vm\n\nThese can be installed on Ubuntu systems via apt-get install libxi-dev libgl1-mesa-dev libglu1-mesa-dev mesa-common-dev libxrandr-dev libxxf86vm-dev\nOn macOS Xquartz is required.")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" FREEGLUT_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" FREEGLUT_DYNAMIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFREEGLUT_BUILD_STATIC_LIBS=${FREEGLUT_STATIC}
        -DFREEGLUT_BUILD_SHARED_LIBS=${FREEGLUT_DYNAMIC}
        -DFREEGLUT_REPLACE_GLUT=ON
        -DFREEGLUT_BUILD_DEMOS=OFF
        -DINSTALL_PDB=OFF # Installing pdbs failed on debug static. So, disable it and let vcpkg_copy_pdbs() do it
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeGLUT)
vcpkg_fixup_pkgconfig()
file(COPY_FILE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/glut.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/freeglut.pc")
if(NOT VCPKG_BUILD_TYPE)
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/glut.pc" " -lfreeglut" " -lfreeglutd")
    endif()
    file(COPY_FILE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/glut.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/freeglut.pc")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/GL/freeglut_std.h"
        "ifdef FREEGLUT_STATIC"
        "if 1 //ifdef FREEGLUT_STATIC"
    )
endif()

# Clean
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/glut")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
