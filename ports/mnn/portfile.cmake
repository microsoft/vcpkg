vcpkg_fail_port_install(ON_TARGET "uwp" "ios" "android")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alibaba/MNN
    REF 1.1.0
    SHA512 3e31eec9a876be571cb2d29e0a2bcdb8209a43a43a5eeae19b295fadfb1252dd5bd4ed5b7c584706171e1b531710248193bc04520a796963e2b21546acbedae0
    HEAD_REF master
    PATCHES
        use-package-and-install.patch
        fix-cuda.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    test        MNN_BUILD_TEST
    tools       MNN_BUILD_TOOLS
    cuda        MNN_CUDA
    vulkan      MNN_VULKAN
    opencl      MNN_OPENCL
)

message(STATUS "Applying feature options")
message(STATUS "  ${FEATURE_OPTIONS}")
if(FEATURE_OPTIONS MATCHES "MNN_BUILD_TEST=ON")
    list(APPEND BUILD_OPTIONS -DMNN_BUILD_BENCHMARK=ON)
endif()
if(FEATURE_OPTIONS MATCHES "MNN_BUILD_TOOLS=ON")
    list(APPEND BUILD_OPTIONS -DMNN_BUILD_QUANTOOLS=ON
                              -DMNN_BUILD_TRAIN=ON 
                              -DMNN_BUILD_DEMO=ON 
                              -DMNN_EVALUATION=ON 
                              -DMNN_BUILD_CONVERTER=ON
    )
endif()
if(FEATURE_OPTIONS MATCHES "MNN_CUDA=ON" OR
   FEATURE_OPTIONS MATCHES "MNN_VULKAN=ON")
    list(APPEND BUILD_OPTIONS -DMNN_GPU_TRACE=ON)
endif()
if(FEATURE_OPTIONS MATCHES "MNN_OPENCL=ON" OR
   FEATURE_OPTIONS MATCHES "MNN_VULKAN=ON")
    list(APPEND BUILD_OPTIONS -DMNN_USE_SYSTEM_LIB=ON)
endif()
message(STATUS "Applying build options")
message(STATUS "  ${BUILD_OPTIONS}")

if(VCPKG_TARGET_IS_WINDOWS)
    # adjust /MD, /MT
    string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" WIN_RUNTIME_MT)
    list(APPEND PLATFORM_OPTIONS -DMNN_WIN_RUNTIME_MT=${WIN_RUNTIME_MT})
elseif(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    # use Metal API by default
    list(APPEND PLATFORM_OPTIONS -DMNN_METAL=ON -DMNN_GPU_TRACE=ON)
endif()
message(STATUS "Applying platform options")
message(STATUS "  ${PLATFORM_OPTIONS}")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMNN_BUILD_SHARED_LIBS=${BUILD_SHARED}
        -DMNN_SEP_BUILD=OFF # build with backends/expression
        ${FEATURE_OPTIONS} ${BUILD_OPTIONS} ${PLATFORM_OPTIONS}
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${CURRENT_PORT_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mnn.metallib
                ${CURRENT_PACKAGES_DIR}/share/${PORT}/mnn.metallib)
endif()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin
                        ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/mnn.metallib)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/cmake")
# vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/${PORT})
