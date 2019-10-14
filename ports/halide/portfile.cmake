include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO halide/Halide
    REF 65c26cba6a3eca2d08a0bccf113ca28746012cc3 #release_2019_08_27
    SHA512 f95b31ec08a6c4e618a5c03b6ae9e0b41888035a268e82ee73abde8ea34dff325db270f1ff10387ef03de27e274ad27c7ccbc873c0b75bb6c1a8112cf3765c5d
    HEAD_REF master
    PATCHES
        fix-install-path.patch
)

set(TARGET_X86 OFF)
set(TARGET_ARM OFF)
set(TARGET_AARCH64 OFF)
if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86 OR VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    # llvm x86 components are required for llvm x64
    set(TARGET_X86 ON)
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
    set(TARGET_X86 OFF)
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
    OPTIONS ${FEATURE_OPTIONS}
        -DTRIPLET_SYSTEM_ARCH=${TRIPLET_SYSTEM_ARCH}
        -DHALIDE_SHARED_LIBRARY=${HALIDE_SHARED_LIBRARY}
        -DTARGET_X86=${TARGET_X86}
        -DTARGET_ARM=${TARGET_ARM}
        -DTARGET_AARCH64=${TARGET_AARCH64}
        #-DTARGET_AMDGPU
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/halide)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
