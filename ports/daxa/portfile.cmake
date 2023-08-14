vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/Ipotrick/Daxa
    REF 14d5378a6157b3530c3ff826182706126be135bd
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    utils-imgui WITH_UTILS_IMGUI
    utils-mem WITH_UTILS_MEM
    utils-pipeline-manager-glslang WITH_UTILS_PIPELINE_MANAGER_GLSLANG
    utils-task-list WITH_UTILS_TASK_LIST
)
set(DAXA_DEFINES)

if(WITH_UTILS_IMGUI)
    list(APPEND DAXA_DEFINES "-DDAXA_ENABLE_UTILS_IMGUI=true")
endif()
if(WITH_UTILS_MEM)
    list(APPEND DAXA_DEFINES "-DDAXA_ENABLE_UTILS_MEM=true")
endif()
if(WITH_UTILS_PIPELINE_MANAGER_GLSLANG)
    list(APPEND DAXA_DEFINES "-DDAXA_ENABLE_UTILS_PIPELINE_MANAGER_GLSLANG=true")
endif()
if(WITH_UTILS_TASK_LIST)
    list(APPEND DAXA_DEFINES "-DDAXA_ENABLE_UTILS_TASK_LIST=true")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${DAXA_DEFINES}
        -DCMAKE_REQUIRE_FIND_PACKAGE_X11=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_WAYLAND=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
