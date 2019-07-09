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
    REF release-0.90.1
    SHA512 99b16b52511fef740fa7a1e234213310a4490b8d7baf4d1e003b93cf4f37b28abf526f6ed2d1e27e9ee2b4949b1957f15c20d4e0f8d30687806fe782780697af
    HEAD_REF master
    PATCHES
        # embedded python uses ignores PYTHONPATH
        0001-fix-embedded-python-path.patch
        # Pkg-config is not available on the Vcpkg CI systems, don't depend on it for the xlib backend
        0002-fix-linux-pkgconfig-dependency.patch
        # Python < 3.6 doesn't allow a WindowsPath object to act as a pathlike in os.path functions
        0003-windows-path-python-fix.patch
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
