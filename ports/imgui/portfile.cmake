include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF bdce8336364595d1a446957a6164c97363349a53 # v1.74
    SHA512 148c949a4d1a07832e97dbf4b3333b728f7207756a95db633daad83636790abe0a335797b2c5a27938453727de43f6abb9f5a5b41909f223ee735ddd1924eb3f
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DIMGUI_SKIP_HEADERS=ON
)

vcpkg_install_cmake()

if ("example" IN_LIST FEATURES)
    if (NOT VCPKG_TARGET_IS_WINDOWS)
        message(FATAL_ERROR "Feature example only support windows.")
    endif()
    
    # Install headers
    file(GLOB IMGUI_EXAMPLE_INCLUDES ${SOURCE_PATH}/examples/*.h)
    file(INSTALL ${IMGUI_EXAMPLE_INCLUDES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

    if ("tools" IN_LIST FEATURES)
        if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
            set(MSBUILD_PLATFORM "Win32")
        else ()
            set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
        endif()
        vcpkg_build_msbuild(
            USE_VCPKG_INTEGRATION
            PROJECT_PATH ${SOURCE_PATH}/examples/imgui_examples.sln
            PLATFORM ${MSBUILD_PLATFORM}
        )
        # Install tools
        file(GLOB_RECURSE IMGUI_EXAMPLE_BINARIES ${SOURCE_PATH}/examples/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
        file(INSTALL ${IMGUI_EXAMPLE_BINARIES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
    endif()
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/imgui/copyright COPYONLY)
