if(EXISTS ${CURRENT_INSTALLED_DIR}/share/microsoft-signalr/copyright)
    message(FATAL_ERROR "'${PORT}' conflicts with 'microsoft-signalr'. Please remove microsoft-signalr:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SignalR/SignalR-Client-Cpp
    REF 1.0.0-beta1
    SHA512 b38f6f946f1499080071949cbcf574405118f9acfb469441e5b5b0df3e5f0d277a83b30e0d613dc5e54732b9071e3273dac1ee65129f994d5a60eef0e45bdf6c
    HEAD_REF master
    PATCHES
        0001_cmake.patch
        0002_fix-compile-error.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        "-DCPPREST_SO=${CURRENT_INSTALLED_DIR}/debug/lib/cpprest_2_10d.lib"
    OPTIONS_RELEASE
        "-DCPPREST_SO=${CURRENT_INSTALLED_DIR}/lib/cpprest_2_10.lib"
    OPTIONS
        "-DCPPREST_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include"
        -DDISABLE_TESTS=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# copy license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
