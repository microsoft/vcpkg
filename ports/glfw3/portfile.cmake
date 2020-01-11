include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glfw/glfw
    REF 3.3.1
    SHA512 f9376002314eae5518ca63738cf1558433007dbf628fb6093a6f54c330f72d85e0ac30049877c50bc99f029e3eb6f69e69508f412d1ec9bdde0ac721dbbeba1e
    HEAD_REF master
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(
"GLFW3 currently requires the following libraries from the system package manager:
    xinerama
    xcursor
    xorg
    libglu1-mesa

These can be installed on Ubuntu systems via sudo apt install libxinerama-dev libxcursor-dev xorg-dev libglu1-mesa-dev")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGLFW_BUILD_EXAMPLES=OFF
        -DGLFW_BUILD_TESTS=OFF
        -DGLFW_BUILD_DOCS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/glfw3)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/glfw3.dll OR EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/glfw3.dll)
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/glfw3.dll ${CURRENT_PACKAGES_DIR}/bin/glfw3.dll)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/glfw3.dll ${CURRENT_PACKAGES_DIR}/debug/bin/glfw3.dll)
        foreach(_conf release debug)
            file(READ ${CURRENT_PACKAGES_DIR}/share/glfw3/glfw3Targets-${_conf}.cmake _contents)
            string(REPLACE "lib/glfw3.dll" "bin/glfw3.dll" _contents "${_contents}")
            file(WRITE ${CURRENT_PACKAGES_DIR}/share/glfw3/glfw3Targets-${_conf}.cmake "${_contents}")
        endforeach()
    endif()
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
