
# It is possible to run into some issues when profiling when we uses Tracy client as a shared client
# As as safety measure let's build Tracy as a static library for now
# More details on Tracy Discord (e.g. https://discord.com/channels/585214693895962624/585214693895962630/953599951328403506)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfpld/tracy
    REF 9ba7171c3dd6f728268a820ee268a62c75f2dfb6
    SHA512 a2898cd04a532a5cc71fd6c5fd3893ebff68df25fc38e8d988ba4a8a6cbe33e3d0049661029d002160b94b57421e5c5b7400658b404e51bfab721d204dd0cc5d
    HEAD_REF master
    PATCHES
        001-cmake-capture-profiler.patch
        002-fix-capstone-5.patch
        003-vcpkg-zstd.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        capture TRACY_BUILD_CAPTURE 
        profiler TRACY_BUILD_PROFILER  
        display-wayland TRACY_USE_WAYLAND  
)

if((TRACY_BUILD_CAPTURE OR TRACY_BUILD_PROFILER) AND VCPKG_TARGET_IS_LINUX)
    message(
"Tracy currently requires the following libraries from the system package manager:
    gtk+-3.0
    tbb

These can be installed on Ubuntu systems via sudo apt install libgtk-3-dev libtbb-dev")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

set(tracy_tools)
if("capture" IN_LIST FEATURES)
    list(APPEND tracy_tools capture)
endif()
if("profiler" IN_LIST FEATURES)
    list(APPEND tracy_tools Tracy)
endif()

list(LENGTH tracy_tools tracy_tools_size)
if(tracy_tools_size GREATER 0)
    vcpkg_copy_tools(TOOL_NAMES ${tracy_tools} AUTO_CLEAN)
endif()

# Cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
