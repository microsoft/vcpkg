set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_fail_port_install(ON_TARGET "uwp")

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(_msvc_runtime_dynamic OFF)
    else()
        set(_msvc_runtime_dynamic ON)
    endif()
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gui         GUI
        stacktrace  STACKTRACE
        webui       WEBUI
)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/glassez/qBittorrent.git
    REF f770971eebec66067b4f498653f3e04a35030ef4
    PATCHES
        fix_qt6_build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        --trace
        ${FEATURE_OPTIONS}
        -DVERBOSE_CONFIGURE=ON
        -DMSVC_RUNTIME_DYNAMIC=${_msvc_runtime_dynamic}
)

vcpkg_install_cmake()

vcpkg_copy_tools(TOOL_NAMES qbittorrent AUTO_CLEAN)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)

configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)