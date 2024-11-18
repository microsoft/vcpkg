vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL
    REF "preview-3.1.6"
    SHA512 a0ca7263cd2f1b883829c39ae0ee2ea18d814f8dde768c8be9a49487193bc856bb45870764fd70169e75d2ec80457e5b45811c07a926479f1ac4f9d3157f40a4
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SDL_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SDL_SHARED)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" FORCE_STATIC_VCRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        alsa     SDL_ALSA
        ibus     SDL_IBUS
        vulkan   SDL_VULKAN
        wayland  SDL_WAYLAND
        x11      SDL_X11
)

if ("x11" IN_LIST FEATURES)
    message(WARNING "You will need to install Xorg dependencies to use feature x11:\nsudo apt install libx11-dev libxft-dev libxext-dev\n")
endif()
if ("wayland" IN_LIST FEATURES)
    message(WARNING "You will need to install Wayland dependencies to use feature wayland:\nsudo apt install libwayland-dev libxkbcommon-dev libegl1-mesa-dev\n")
endif()
if ("ibus" IN_LIST FEATURES)
    message(WARNING "You will need to install ibus dependencies to use feature ibus:\nsudo apt install libibus-1.0-dev\n")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSDL_STATIC=${SDL_STATIC}
        -DSDL_SHARED=${SDL_SHARED}
        -DSDL_FORCE_STATIC_VCRT=${FORCE_STATIC_VCRT}
        -DSDL_LIBC=ON
        -DSDL_TEST_LIBRARY=OFF
        -DSDL_TESTS=OFF
        -DSDL_INSTALL_CMAKEDIR_ROOT=share/${PORT}
        # Specifying the revision skips the need to use git to determine a version
        -DSDL_REVISION=vcpkg
        -DCMAKE_DISABLE_FIND_PACKAGE_LibUSB=1
    MAYBE_UNUSED_VARIABLES
        SDL_FORCE_STATIC_VCRT
)

vcpkg_cmake_install()

# Subject to https://github.com/libsdl-org/SDL/pull/11492
set(config_path "share/${PORT}/SDL3")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(config_path "share/${PORT}")
endif()
vcpkg_cmake_config_fixup(CONFIG_PATH "${config_path}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt"
    COMMENT "Some configurations may use code licensed under the MIT and Apache-2.0 licenses."
)
