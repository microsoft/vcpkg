if (VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_IOS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

# X.Y.Z => vX_Y_Z
string(REPLACE "." "_" version_tag ${VERSION})
set(version_tag "v${version_tag}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PixarAnimationStudios/OpenSubdiv
    REF ${version_tag}
    SHA512 b929aa638cb60ce3dd9e03dc6d1b981f793f5671448aedeb5f3bdfd9297e7e6ee114f1a7bf91c6f708045f8cb1e320afd3c25168e7dd0fa9dffaedad4dd0a66f
    HEAD_REF release
    PATCHES
        fix_compile-option.patch
        fix-build-type.patch
        fix-dependencies.patch
        fix-find-dependencies.patch
        fix-openmp-library.patch
        fix-android-install.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

if (VCPKG_CRT_LINKAGE STREQUAL static)
    set(STATIC_CRT_LNK ON)
else()
    set(STATIC_CRT_LNK OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "true-deriv-eval"     OPENSUBDIV_GREGORY_EVAL_TRUE_DERIVATIVES
        "patch-shader-source" OSD_PATCH_SHADER_SOURCE_GLSL
        "patch-shader-source" OSD_PATCH_SHADER_SOURCE_HLSL
    INVERTED_FEATURES
        "cuda"      NO_CUDA
        "dx"        NO_DX
        "glew"      NO_GLEW
        "metal"     NO_METAL
        "omp"       NO_OMP
        "opencl"    NO_OPENCL
        "opengl"    NO_OPENGL
        "tbb"       NO_TBB
)

# MSL codegen needs Objective-C
set(FEATURE_OPTIONS_APPLE "-DOSD_PATCH_SHADER_SOURCE_MSL=OFF")
if (VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS_APPLE
        FEATURES
            "patch-shader-source" OSD_PATCH_SHADER_SOURCE_MSL
    )
endif()

set(OSD_EXTRA_OPTS)
if("glew" IN_LIST FEATURES)
    list(APPEND OSD_EXTRA_OPTS -DGLEW_LOCATION=${CURRENT_INSTALLED_DIR})
endif()
if("dx" IN_LIST FEATURES)
    list(APPEND OSD_EXTRA_OPTS -DDXSDK_LOCATION=${CURRENT_INSTALLED_DIR})
endif()

if("cuda" IN_LIST FEATURES)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DMSVC_STATIC_CRT=${STATIC_CRT_LNK}
        -DNO_LIB=OFF
        -DNO_REGRESSION=ON
        -DNO_DOC=ON
        -DNO_TESTS=ON
        -DNO_GLTESTS=ON
        -DNO_CLEW=ON
        -DNO_EXAMPLES=ON
        -DNO_TUTORIALS=ON
        -DNO_GLFW=ON
        -DNO_PTEX=ON
        ${FEATURE_OPTIONS}
        ${FEATURE_OPTIONS_APPLE}
        ${OSD_EXTRA_OPTS}
    MAYBE_UNUSED_VARIABLES
        MSVC_STATIC_CRT
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME OpenSubdiv CONFIG_PATH lib/cmake/OpenSubdiv)
vcpkg_fixup_pkgconfig()

# The header files are read only and can't remove when remove this port
file(GLOB_RECURSE OSD_HDRS "${CURRENT_PACKAGES_DIR}/include/*.h")
file(CHMOD_RECURSE ${OSD_HDRS}
        PERMISSIONS
            OWNER_READ OWNER_WRITE
            GROUP_READ GROUP_WRITE
            WORLD_READ WORLD_WRITE
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/bin"
                    "${CURRENT_PACKAGES_DIR}/debug/bin"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
