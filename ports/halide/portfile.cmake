include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO halide/Halide
    REF release_2018_02_15
    SHA512 ef8b0fea7bc52fe3db59ea6f0cd433f2f309550d0338ff88b631bde5ffb3c8e2d3c2a27ae5154ef18942eb5f7decb50b26ff9469e861bb1707fbc4f9e3a67aaf
    HEAD_REF master
    PATCHES
        fix-code-error.patch
        fix-build-error.patch
)

set(TARGET_X86 OFF)
set(TARGET_ARM OFF)
set(TARGET_AARCH64 OFF)
if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    set(TARGET_X86 ON)
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(TARGET_X86 OFF)
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
    if (TARGET_TRIPLET STREQUAL arm64)
        set(TARGET_AARCH64 ON)
    else()
        set(TARGET_ARM ON)
    endif()
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(HALIDE_SHARED_LIBRARY ON)
else()
    set(HALIDE_SHARED_LIBRARY OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    app WITH_APPS
    test WITH_TESTS
    tutorials WITH_TUTORIALS
    docs WITH_DOCS
    utils WITH_UTILS
    nativeclient TARGET_NATIVE_CLIENT
    hexagon TARGET_HEXAGON
    metal TARGET_METAL
    mips TARGET_MIPS
    powerpc TARGET_POWERPC
    ptx TARGET_PTX
    opencl TARGET_OPENCL
    opengl TARGET_OPENGL
    opengl TARGET_OPENGLCOMPUTE
    rtti HALIDE_ENABLE_RTTI
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTRIPLET_SYSTEM_ARCH=${TRIPLET_SYSTEM_ARCH}
        -DHALIDE_SHARED_LIBRARY=${HALIDE_SHARED_LIBRARY}
        -DTARGET_X86=${TARGET_X86}
        -DTARGET_ARM=${TARGET_ARM}
        -DTARGET_AARCH64=${TARGET_AARCH64}
        #-DTARGET_AMDGPU
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(INSTALL ${SOURTH_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
