if (VCPKG_TARGET_ARCHITECTURE MATCHES "^arm*")
  message(FATAL_ERROR "OpenXR does not support arm")
endif()

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  # Due to UWP restricting the usage of static CRT OpenXR cannot be built.
  message(FATAL_ERROR "OpenXR does not support UWP")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jherico/OpenXR-SDK
    REF 55e82840d2e28aac4c15d8c713d53937d58de54d
    SHA512 30481dbe682de277f4a36c98de80761cbacd40256955072ab5f7ba3993ce7f23becf6e4c908e32b1dce66317c71ea70a4264d7e21d56d2a547d52742c01371f2
    HEAD_REF master
)

# Weird behavior inside the OpenXR loader.  On Windows they force shared libraries to use static crt, and
# vice-versa.  Might be better in future iterations to patch the CMakeLists.txt for OpenXR
if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        set(DYNAMIC_LOADER OFF)
        set(VCPKG_CRT_LINKAGE dynamic)
    else()
        set(DYNAMIC_LOADER ON)
        set(VCPKG_CRT_LINKAGE static)
    endif()
endif()

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_API_LAYERS=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_CONFORMANCE_TESTS=OFF
        -DDYNAMIC_LOADER=${DYNAMIC_LOADER}
        -DPYTHON_EXECUTABLE=${PYTHON3}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
# No CMake files are contained in /share only docs
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openxr-loader RENAME copyright)

vcpkg_copy_pdbs()
