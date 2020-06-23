vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

# If you update the version, you MUST regenerate the OpenXR.hpp file and include it in the PR
# See below where we copy the openxr.hpp from the ports directory to the installation directory
# The openxr.hpp build process depends on the specific OpenXR version, but it hasn't yet be 
# incorporated into the official build process, hence this bit of hackery
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK
    REF 97cfe495bb7a3853266b646d1c79e169387f9c7a
    SHA512 794c546d4b240e8f502caf0cf64174d7d72801999260bba9579d9ddd5f3815c3dd0b2da006a6e22164284670e603f4348d1ea2ff6e6852554b2ef1039114dee7
    HEAD_REF master
)

# Weird behavior inside the OpenXR loader.  On Windows they force shared libraries to use static crt, and
# vice-versa.  Might be better in future iterations to patch the CMakeLists.txt for OpenXR
if (VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_WINDOWS)
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

file(COPY ${CMAKE_CURRENT_LIST_DIR}/openxr.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/openxr)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
# No CMake files are contained in /share only docs
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
