include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.sourceforge.net/project/freeglut/freeglut/3.2.1/freeglut-3.2.1.tar.gz"
    FILENAME "freeglut-3.2.1.tar.gz"
    SHA512 aced4bbcd36269ce6f4ee1982e0f9e3fffbf18c94f785d3215ac9f4809b992e166c7ada496ed6174e13d77c0f7ef3ca4c57d8a282e96cbbe6ff086339ade3b08
)

vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  PATCHES
    use_targets_to_export_x11_dependency.patch
    macOS_Xquartz.patch
    install_glut_h.patch
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

# Copy static lib (otherwise it's incompatible with FindGLUT.cmake)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        file(COPY ${CURRENT_PACKAGES_DIR}/lib/freeglut_static.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/freeglut.lib)
        file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/freeglut_staticd.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/freeglutd.lib)
    endif()
endif()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/freeglut)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/freeglut/COPYING ${CURRENT_PACKAGES_DIR}/share/freeglut/copyright)

vcpkg_copy_pdbs()
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/glut)
endif()
