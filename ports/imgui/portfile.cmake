vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF bdce8336364595d1a446957a6164c97363349a53 #v1.74
    SHA512 148c949a4d1a07832e97dbf4b3333b728f7207756a95db633daad83636790abe0a335797b2c5a27938453727de43f6abb9f5a5b41909f223ee735ddd1924eb3f
    HEAD_REF master
)

file(COPY ${CURRENT_PORT_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if ("example" IN_LIST FEATURES)
    vcpkg_check_linkage(ONLY_STATIC_CRT)
    
    if (NOT VCPKG_TARGET_IS_WINDOWS)
        message(FATAL_ERROR "Feature example only support windows.")
    endif()
    
    if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(BUILD_ARCH "Win32")
    elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(BUILD_ARCH "x64")
    else()
        message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()
    
    vcpkg_build_msbuild(
        USE_VCPKG_INTEGRATION
        PROJECT_PATH ${SOURCE_PATH}/examples/imgui_examples.sln
        PLATFORM ${BUILD_ARCH}
    )
    
    # Install tools
    file(GLOB_RECURSE IMGUI_EXAMPLE_BINARIES ${SOURCE_PATH}/examples/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    file(INSTALL ${IMGUI_EXAMPLE_BINARIES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${CURRENT_PORT_DIR}/Findimgui.cmake ${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/imgui)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
