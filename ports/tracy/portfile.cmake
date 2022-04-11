
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
        001-fix-vcxproj-vcpkg.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        capture TRACY_BUILD_CAPTURE 
        profiler TRACY_BUILD_PROFILER  
        display-wayland TRACY_USE_WAYLAND  
)

if(VCPKG_TARGET_IS_LINUX)
    if(TRACY_BUILD_CAPTURE OR TRACY_BUILD_PROFILER)
        message(
    "Tracy currently requires the following libraries from the system package manager to build its tools:
        gtk+-3.0
        tbb

    These can be installed on Ubuntu systems via sudo apt install libgtk-3-dev libtbb-dev")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)
vcpkg_cmake_install()

if("capture" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_install_msbuild(
            SOURCE_PATH "${SOURCE_PATH}"
            PROJECT_SUBPATH "capture/build/win32/capture.vcxproj"
            USE_VCPKG_INTEGRATION
        )
    else()
    endif()
endif()

if("csvexport" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_install_msbuild(
            SOURCE_PATH "${SOURCE_PATH}"
            PROJECT_SUBPATH "csvexport/build/win32/csvexport.vcxproj"
            USE_VCPKG_INTEGRATION
        )
    else()
    endif()
endif()

if("import-chrome" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_install_msbuild(
            SOURCE_PATH "${SOURCE_PATH}"
            PROJECT_SUBPATH "import-chrome/build/win32/import-chrome.vcxproj"
            USE_VCPKG_INTEGRATION
        )
    else()
    endif()
endif()

if("profiler" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_install_msbuild(
            SOURCE_PATH "${SOURCE_PATH}"
            PROJECT_SUBPATH "profiler/build/win32/Tracy.vcxproj"
            USE_VCPKG_INTEGRATION
        )
    else()
    endif()
endif()

if("update" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_install_msbuild(
            SOURCE_PATH "${SOURCE_PATH}"
            PROJECT_SUBPATH "update/build/win32/update.vcxproj"
            USE_VCPKG_INTEGRATION
        )
    else()
    endif()
endif()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")