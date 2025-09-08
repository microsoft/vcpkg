vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeGLUTProject/freeglut
    REF "v${VERSION}"
    SHA512 9be8dcc266daacc21aa0e11261bfe864260de6802e98e7dc84964904df4a89e52960eba94d58f4c18fc1f0ff3f13810d59fc33313c2a6e3f07d18f0b50b95849
    HEAD_REF master
    PATCHES
        android.patch
        x11-dependencies-export.patch
        fix-debug-macro.patch
        windows-output-name.patch
        cmake-version.patch
)

if(VCPKG_TARGET_IS_OSX)
    message("Freeglut currently requires Xquartz for macOS.")
elseif(NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_ANDROID)
    message("Freeglut currently requires the following libraries from the system package manager:\n    opengl\n    glu\n    libx11\n    xrandr\n    xi\n    xxf86vm\n\nThese can be installed on Ubuntu systems via apt-get install libxi-dev libgl1-mesa-dev libglu1-mesa-dev mesa-common-dev libxrandr-dev libxxf86vm-dev")
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

file(GLOB pc_files "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc"  "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*.pc")
foreach(file IN LISTS pc_files)
    vcpkg_replace_string("${file}" ";-D" " -D" IGNORE_UNCHANGED)
endforeach()

if(NOT VCPKG_TARGET_IS_ANDROID)
    file(COPY_FILE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/glut.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/freeglut.pc")
    if(NOT VCPKG_BUILD_TYPE)
        if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/glut.pc" " -lfreeglut" " -lfreeglutd" IGNORE_UNCHANGED)
        endif()
        file(COPY_FILE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/glut.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/freeglut.pc")
    endif()
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
