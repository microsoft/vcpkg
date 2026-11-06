string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" OPEN3D_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" OPEN3D_STATIC_WINDOWS_RUNTIME)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isl-org/Open3D
    REF 408890c3d940211228d85d86d12972ab82336f25
    SHA512 e931055fbf74623e20b4f15de23e84ea4943d73844d267a52122808b28db12e9af2b200c8fdba19c1321823b283b612b595bebb54915dfc6b1187bec8c9f18e1
    HEAD_REF main
    PATCHES
        disable-tools-apps.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_SHARED_LIBS=${OPEN3D_BUILD_SHARED}
        -DOPEN3D_USE_VCPKG=ON
        -DBUILD_TOOLS=OFF
        -DBUILD_APPS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_PYTHON_MODULE=OFF
        -DBUILD_CUDA_MODULE=OFF
        -DWITH_STUBGEN=OFF
        -DBUILD_GUI=OFF
        -DBUILD_WEBRTC=OFF
        -DBUILD_JUPYTER_EXTENSION=OFF
        -DBUILD_ISPC_MODULE=OFF
        # X11 is not a declared dependency; keep the build deterministic by
        # never letting FindX11 pick up whatever happens to be on the machine.
        -DCMAKE_DISABLE_FIND_PACKAGE_X11=ON
        -DWITH_IPP=OFF
        -DWITH_MINIZIP=ON
        -DBUILD_LIBREALSENSE=OFF
        -DBUILD_AZURE_KINECT=OFF
        -DBUILD_TENSORFLOW_OPS=OFF
        -DBUILD_PYTORCH_OPS=OFF
        -DBUNDLE_OPEN3D_ML=OFF
        -DBUILD_VTK_FROM_SOURCE=OFF
        -DUSE_SYSTEM_VTK=ON
        -DDEVELOPER_BUILD=OFF
        -DSTATIC_WINDOWS_RUNTIME=${OPEN3D_STATIC_WINDOWS_RUNTIME}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# OpenBLAS (aarch64) is fetched as an ExternalProject at build time;
# capture its license for the copyright file.
set(extra_copyright_files "")
foreach(thirdparty IN ITEMS openblas)
    set(thirdparty_license "${CURRENT_BUILDTREE_DIR}/${thirdparty}/${thirdparty}-prefix/src/ext_${thirdparty}/LICENSE")
    if(EXISTS "${thirdparty_license}")
        file(COPY_FILE "${thirdparty_license}" "${CURRENT_BUILDTREE_DIR}/${thirdparty}-LICENSE")
        list(APPEND extra_copyright_files "${CURRENT_BUILDTREE_DIR}/${thirdparty}-LICENSE")
    endif()
endforeach()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Open3D)
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/open3d/Open3DConfig.cmake"
    "include(CMakeFindDependencyMacro)"
    "include(CMakeFindDependencyMacro)\nfind_dependency(zstd CONFIG)"
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/open3d/data/dataset"
    "${CURRENT_PACKAGES_DIR}/include/open3d/io/file_format"
    "${CURRENT_PACKAGES_DIR}/include/open3d/ml/tensorflow/tf_subsampling"
    "${CURRENT_PACKAGES_DIR}/include/open3d/t/io/file_format"
    "${CURRENT_PACKAGES_DIR}/include/open3d/visualization/gui/Materials"
    "${CURRENT_PACKAGES_DIR}/include/open3d/visualization/gui/Resources"
    "${CURRENT_PACKAGES_DIR}/include/open3d/visualization/rendering/gaussian_splat/shaders"
    "${CURRENT_PACKAGES_DIR}/include/open3d/visualization/shader/glsl"
    "${CURRENT_PACKAGES_DIR}/include/open3d/visualization/webrtc_server/html"
)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    # The build compiles in third-party code that is downloaded at build time
    # or bundled under 3rdparty/, each under its own license.
    "${SOURCE_PATH}/3rdparty/dirent/LICENSE"
    "${SOURCE_PATH}/3rdparty/liblzf/LICENSE"
    "${SOURCE_PATH}/3rdparty/possionrecon/LICENSE"
    "${SOURCE_PATH}/3rdparty/rply/LICENSE"
    "${SOURCE_PATH}/3rdparty/tinyfiledialogs/LICENSE"
    "${SOURCE_PATH}/3rdparty/tomasakeninemoeller/LICENSE"
    "${SOURCE_PATH}/3rdparty/uvatlas/LICENSE_directxheaders"
    "${SOURCE_PATH}/3rdparty/uvatlas/LICENSE_directxmath"
    "${SOURCE_PATH}/3rdparty/uvatlas/LICENSE_uvatlas"
    "${CURRENT_PORT_DIR}/spz-license.txt"
    # Vulkan-Headers and VulkanMemoryAllocator headers are installed under
    # include/open3d/3rdparty; their archives carry no license files.
    "${CURRENT_PORT_DIR}/vulkan-headers-license.md"
    "${CURRENT_PORT_DIR}/vkmemalloc-license.txt"
    "${CURRENT_PORT_DIR}/vmahpp-license.txt"
    # x64 builds statically link MKL binaries downloaded by the build system
    # (Intel Simplified Software License, which permits binary redistribution).
    "${CURRENT_PORT_DIR}/mkl-license.txt"
    ${extra_copyright_files}
)
