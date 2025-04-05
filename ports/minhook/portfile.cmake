if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(BUILD_ARCH "Win32")
    set(OUTPUT_DIR "Win32")
elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
    set(BUILD_ARCH "x64")
    set(OUTPUT_DIR "Win64")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

# Download files to enable CMake support for minhook - Adds CMakeLists.txt and minhook-config.cmake.in
vcpkg_download_distfile(
    CMAKE_SUPPORT_PATCH
    URLS https://github.com/TsudaKageyu/minhook/commit/3f2e34976c1685ee372a09f54c0c8c8f4240ef90.patch?full_index=1
    FILENAME minhook-cmake-support.patch
    SHA512 7863c51a4563fbc3694149595a7ef301500a1b3b324cc5571b0843386c2fdb5ae10b7e830c9b9fcc973dd17f77f386fd1dedcd493ce8475d2dcf2c44bb7306d0
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TsudaKageyu/minhook
    REF "v${VERSION}"
    SHA512 9f10c92a926a06cde1e4092b664a3aab00477e8b9f20cee54e1d2b3747fad91043d199a2753f7e083497816bbefc5d75d9162d2098dd044420dbca555e80b060
    HEAD_REF master
    PATCHES
        "${CMAKE_SUPPORT_PATCH}"
        fix-usage.patch
        fix-cmake-version.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/minhook)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
