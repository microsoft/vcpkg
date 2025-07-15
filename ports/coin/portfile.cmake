if(NOT VCPKG_HOST_IS_WINDOWS)
    message(WARNING "${PORT} currently requires the following programs from the system package manager:
    libgl libglu
On Debian and Ubuntu derivatives:
    sudo apt-get install libgl-dev libglu1-mesa-dev
On CentOS and recent Red Hat derivatives:
    yum install mesa-libGL-devel mesa-libGLU-devel
On Fedora derivatives:
    sudo dnf install mesa-libGL-devel mesa-libGLU-devel
On Arch Linux and derivatives:
    sudo pacman -S gl glu
On Alpine:
    apk add gl glu\n")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Coin3D/coin
    REF "v${VERSION}"
    SHA512 5e9505efda536a6687fd1cfcc4589af9bfbdbd4a8d660335c060e1678f84c5db91415e0a40ee7b4b40e5894d7330172a24f822d38c0ea276badb92fc68efeec8
    HEAD_REF master
    PATCHES
        remove-default-config.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(COIN_BUILD_SHARED_LIBS OFF)
else()
    set(COIN_BUILD_SHARED_LIBS ON)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(COIN_BUILD_MSVC_STATIC_RUNTIME OFF)
elseif(VCPKG_CRT_LINKAGE STREQUAL static)
    set(COIN_BUILD_MSVC_STATIC_RUNTIME ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
  superglu USE_SUPERGLU
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=11 # Boost v1.84.0 libraries require C++11
        -DCOIN_BUILD_DOCUMENTATION=OFF
        -DCOIN_BUILD_MSVC_STATIC_RUNTIME=${COIN_BUILD_MSVC_STATIC_RUNTIME}
        -DCOIN_BUILD_SHARED_LIBS=${COIN_BUILD_SHARED_LIBS}
        -DCOIN_BUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Coin-${VERSION})

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Coin/profiler")

vcpkg_fixup_pkgconfig()
