vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ipotrick/Daxa
    REF ${VERSION}
    SHA512 2cdb653be68e9c70fd023d1d3c450830b9fb9fcd3d7257e85715390f422501ae17633b01fdc1b9da7b9563ace1c4b524f8b69e5a24636b387b7960b52906ed94
    HEAD_REF master
    PATCHES
        daxa_swp_current_cpu_timeline_value.patch # fix std::max(long long int, long int), as int64_t is long int on some platforms
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    utils-imgui WITH_UTILS_IMGUI
    utils-mem WITH_UTILS_MEM
    utils-pipeline-manager-glslang WITH_UTILS_PIPELINE_MANAGER_GLSLANG
    utils-pipeline-manager-slang WITH_UTILS_PIPELINE_MANAGER_SLANG
    utils-pipeline-manager-spirv-validation WITH_UTILS_PIPELINE_MANAGER_SPIRV_VALIDATION
    utils-task-graph WITH_UTILS_TASK_GRAPH
)
set(DAXA_DEFINES "-DDAXA_INSTALL=true")

if(WITH_UTILS_IMGUI)
    list(APPEND DAXA_DEFINES "-DDAXA_ENABLE_UTILS_IMGUI=true")
endif()
if(WITH_UTILS_MEM)
    list(APPEND DAXA_DEFINES "-DDAXA_ENABLE_UTILS_MEM=true")
endif()
if(WITH_UTILS_PIPELINE_MANAGER_GLSLANG)
    list(APPEND DAXA_DEFINES "-DDAXA_ENABLE_UTILS_PIPELINE_MANAGER_GLSLANG=true")
endif()
if(WITH_UTILS_PIPELINE_MANAGER_SLANG)
    list(APPEND DAXA_DEFINES "-DDAXA_ENABLE_UTILS_PIPELINE_MANAGER_SLANG=true")
endif()
if(WITH_UTILS_PIPELINE_MANAGER_SPIRV_VALIDATION)
    list(APPEND DAXA_DEFINES "-DDAXA_ENABLE_UTILS_PIPELINE_MANAGER_SPIRV_VALIDATION=true")
endif()
if(WITH_UTILS_TASK_GRAPH)
    list(APPEND DAXA_DEFINES "-DDAXA_ENABLE_UTILS_TASK_GRAPH=true")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${DAXA_DEFINES}
        -DCMAKE_REQUIRE_FIND_PACKAGE_X11=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_WAYLAND=ON
    MAYBE_UNUSED_VARIABLES
        CMAKE_REQUIRE_FIND_PACKAGE_X11
        CMAKE_REQUIRE_FIND_PACKAGE_WAYLAND
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
