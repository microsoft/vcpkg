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

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(HALIDE_SHARED_LIBRARY ON)
else()
    set(HALIDE_SHARED_LIBRARY OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTRIPLET_SYSTEM_ARCH=${TRIPLET_SYSTEM_ARCH}
        -DHALIDE_SHARED_LIBRARY=${HALIDE_SHARED_LIBRARY}
        #-DTARGET_X86
        #-DTARGET_ARM
        #-DTARGET_AARCH64
        #-DTARGET_HEXAGON
        #-DTARGET_METAL
        #-DTARGET_MIPS
        #-DTARGET_POWERPC
        #-DTARGET_PTX
        #-DTARGET_AMDGPU
        #-DTARGET_OPENCL
        #-DTARGET_OPENGL
        #-DTARGET_OPENGLCOMPUTE
        #-DHALIDE_ENABLE_RTTI
        -DTARGET_NATIVE_CLIENT=OFF
        -DWARNINGS_AS_ERRORS=OFF
        -DWITH_TESTS=OFF
        -DWITH_APPS=OFF
        -DWITH_TUTORIALS=OFF
        -DWITH_DOCS=OFF
        -DWITH_UTILS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(INSTALL ${SOURTH_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
