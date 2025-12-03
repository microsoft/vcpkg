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
    SHA512 4594f1b23a32298b2fc3ce77287fba7c76c9912e17aa596f5f45aae300775fc2794e5c47720767a0116b981306a60c3ca70729fdab17d1476696834507d78c75
    HEAD_REF master
    PATCHES
        expat.diff
        openal.diff
        remove-default-config.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/src/xml/expat")
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/FindFontconfig.cmake")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" COIN_BUILD_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" COIN_BUILD_MSVC_STATIC_RUNTIME)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bzip2       VCPKG_LOCK_FIND_PACKAGE_BZip2
        fontconfig  VCPKG_LOCK_FIND_PACKAGE_Fontconfig
        freetype    VCPKG_LOCK_FIND_PACKAGE_Freetype
        openal      VCPKG_LOCK_FIND_PACKAGE_OpenAL
        simage      VCPKG_LOCK_FIND_PACKAGE_simage
        superglu    USE_SUPERGLU
        superglu    VCPKG_LOCK_FIND_PACKAGE_superglu
        zlib        VCPKG_LOCK_FIND_PACKAGE_ZLIB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=11 # Boost v1.84.0 libraries require C++11
        -DCOIN_BUILD_DOCUMENTATION=OFF
        -DCOIN_BUILD_MSVC_STATIC_RUNTIME=${COIN_BUILD_MSVC_STATIC_RUNTIME}
        -DCOIN_BUILD_SHARED_LIBS=${COIN_BUILD_SHARED_LIBS}
        -DCOIN_BUILD_TESTS=OFF
        -DUSE_EXTERNAL_EXPAT=ON
        -DFONTCONFIG_RUNTIME_LINKING=OFF
        -DFREETYPE_RUNTIME_LINKING=OFF
        -DGLU_RUNTIME_LINKING=OFF
        -DLIBBZIP2_RUNTIME_LINKING=OFF
        -DOPENAL_RUNTIME_LINKING=OFF
        -DSIMAGE_RUNTIME_LINKING=OFF
        -DSPIDERMONKEY_RUNTIME_LINKING=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_SpiderMonkey=OFF
        -DZLIB_RUNTIME_LINKING=OFF
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        COIN_BUILD_MSVC_STATIC_RUNTIME
        VCPKG_LOCK_FIND_PACKAGE_superglu
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Coin-${VERSION})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Coin/profiler")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
