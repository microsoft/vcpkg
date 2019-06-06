include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glfw/glfw
    REF 3.3
    SHA512 e74bb7ba0c1c3a524a193c4fb5a2d13ba0e75f8e309612ea19cdcc944859d6e2fe29d8b2e3db76236e1011b637564ddd5f4a176dcccfeb84d09bda060f08f774
    HEAD_REF master
    PATCHES move-cmake-min-req.patch
)

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(
"GLFW3 currently requires the following libraries from the system package manager:
    xinerama
    xcursor

These can be installed on Ubuntu systems via sudo apt install libxinerama-dev libxcursor-dev")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
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

file(COPY ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/glfw3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glfw3/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/glfw3/copyright)

vcpkg_copy_pdbs()
