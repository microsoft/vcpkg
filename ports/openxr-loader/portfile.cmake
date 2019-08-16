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
    REPO KhronosGroup/OpenXR-SDK
    REF release-1.0.0
    SHA512 423079b841a01f3b51283839c565cfa1b8ff38348c3f3d6f62e9120569d4ad540d8d6bfe8010e74d9bbb76aeaedcf273e5e3b1717bb0b424898793fb4712aa58
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

function(COPY_BINARIES SOURCE DEST)
    # hack, because CMAKE_SHARED_LIBRARY_SUFFIX seems to be unpopulated
    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(SHARED_LIB_SUFFIX ".dll")
    else()
        set(SHARED_LIB_SUFFIX ".so")
    endif()
    file(MAKE_DIRECTORY ${DEST})
    file(GLOB_RECURSE SHARED_BINARIES ${SOURCE}/*${SHARED_LIB_SUFFIX})
    file(COPY ${SHARED_BINARIES} DESTINATION ${DEST})
    file(REMOVE_RECURSE ${SHARED_BINARIES})
endfunction()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
# No CMake files are contained in /share only docs
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openxr-loader RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    COPY_BINARIES(${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/bin)
    COPY_BINARIES(${CURRENT_PACKAGES_DIR}/debug/lib ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()
