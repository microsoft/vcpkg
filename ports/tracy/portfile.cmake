
# It is possible to run into some issues when profiling when we uses Tracy client as a shared client
# As as safety measure let's build Tracy as a static library for now
# More details on Tracy Discord (e.g. https://discord.com/channels/585214693895962624/585214693895962630/953599951328403506)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfpld/tracy
    REF v0.10
    SHA512 3fc406a42380f6ebe671d560482733f3cdbca16dd7721ac2fce8f1cdefb96ba87701714c2ee8161d65d9e185bc5f9a0fe587a3843eb75f851b10eb895358cb64
    HEAD_REF master
    PATCHES
        001-fix-vcxproj-vcpkg.patch
        003-fix-imgui-path.patch
        005-fix-imgui-path-legacy.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        on-demand TRACY_ON_DEMAND
    INVERTED_FEATURES
        crash-handler TRACY_NO_CRASH_HANDLER
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

function(tracy_tool_install_unix tracy_TOOL tracy_TOOL_NAME)
    foreach(buildtype IN ITEMS "debug" "release")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "${buildtype}")
            if("${buildtype}" STREQUAL "debug")
                set(short_buildtype "-dbg")
                set(path_suffix "/debug")
            else()
                set(short_buildtype "-rel")
                set(path_suffix "")
            endif()

            file(COPY "${SOURCE_PATH}/${tracy_TOOL}/build/unix" DESTINATION "${SOURCE_PATH}/${tracy_TOOL}/_build")
            file(RENAME "${SOURCE_PATH}/${tracy_TOOL}/_build/unix" "${SOURCE_PATH}/${tracy_TOOL}/build/unix${short_buildtype}")
            file(REMOVE_RECURSE "${SOURCE_PATH}/${tracy_TOOL}/_build")

            set(path_makefile_dir "${SOURCE_PATH}/${tracy_TOOL}/build/unix${short_buildtype}")
            cmake_path(RELATIVE_PATH path_makefile_dir 
                BASE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${short_buildtype}"
                OUTPUT_VARIABLE relative_path_makefile_dir)

            set(ENV{LEGACY} 1)
            vcpkg_backup_env_variables(VARS PKG_CONFIG_PATH)
            vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}${path_suffix}/lib/pkgconfig")

            message(STATUS "Building ${tracy_TOOL_NAME} ${TARGET_TRIPLET}${short_buildtype}")
            vcpkg_build_make(
                BUILD_TARGET ${buildtype}
                SUBPATH ${relative_path_makefile_dir}
                LOGFILE_ROOT "build-${tracy_TOOL}"
            )
            vcpkg_restore_env_variables(VARS PKG_CONFIG_PATH)

            file(INSTALL "${SOURCE_PATH}/${tracy_TOOL}/build/unix${short_buildtype}/${tracy_TOOL_NAME}-${buildtype}"
                DESTINATION "${CURRENT_PACKAGES_DIR}${path_suffix}/tools/${PORT}"
                RENAME "${tracy_TOOL_NAME}"
                USE_SOURCE_PERMISSIONS)
        endif()
    endforeach()
endfunction()

function(tracy_tool_install_win32 tracy_TOOL tracy_TOOL_NAME)
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "${tracy_TOOL}/build/win32/${tracy_TOOL_NAME}.sln"
        USE_VCPKG_INTEGRATION
    )
endfunction()

function(tracy_tool_install tracy_TOOL tracy_TOOL_NAME)
    if(VCPKG_TARGET_IS_WINDOWS)
        tracy_tool_install_win32("${tracy_TOOL}" "${tracy_TOOL_NAME}")
    else()
        tracy_tool_install_unix("${tracy_TOOL}" "${tracy_TOOL_NAME}")
    endif()
endfunction()

if("cli-tools" IN_LIST FEATURES)
    tracy_tool_install(capture capture)
    tracy_tool_install(csvexport csvexport)
    tracy_tool_install(import-chrome import-chrome)
    tracy_tool_install(update update)
endif()
if("gui-tools" IN_LIST FEATURES)
    tracy_tool_install(profiler Tracy)
endif()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME Tracy)
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
