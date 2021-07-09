vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO seladb/PcapPlusPlus
    REF v21.05
    SHA512 35227707a48f0e41469247e0993c4aabef7f168a285354e19386b554e0e3d51dc6bf8b128658e16d50e0b6e6e0a029322dee1b4b241e84b8603e2cf73c7f3532
    HEAD_REF master
    PATCHES
        Common++.vcxproj.template.patch
        Packet++.vcxproj.template.patch
        Pcap++.vcxproj.template.patch
        LightPcapNg.vcxproj.template.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_PLATFORM_TOOLSET STREQUAL "v140")
        set(VS_VERSION "vs2015")
    elseif(VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
        set(VS_VERSION "vs2017")
    elseif(VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
        set(VS_VERSION "vs2019")
    else()
        message(FATAL_ERROR "Unsupported visual studio version")
    endif()

    vcpkg_execute_required_process(
        COMMAND configure-windows-visual-studio.bat -v ${VS_VERSION} -w . -p .
        WORKING_DIRECTORY ${SOURCE_PATH}
    )

    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "mk/${VS_VERSION}/Common++.vcxproj"
        PLATFORM ${TRIPLET_SYSTEM_ARCH}
        INCLUDES_SUBPATH Dist/header
        ALLOW_ROOT_INCLUDES
        USE_VCPKG_INTEGRATION
    )
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "mk/${VS_VERSION}/Packet++.vcxproj"
        PLATFORM ${TRIPLET_SYSTEM_ARCH}
        INCLUDES_SUBPATH Dist/header
        ALLOW_ROOT_INCLUDES
        USE_VCPKG_INTEGRATION
    )
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "mk/${VS_VERSION}/Pcap++.vcxproj"
        PLATFORM ${TRIPLET_SYSTEM_ARCH}
        USE_VCPKG_INTEGRATION
        INCLUDES_SUBPATH Dist/header
        ALLOW_ROOT_INCLUDES
        LICENSE_SUBPATH LICENSE
    )

    file(
        REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/tools" "${CURRENT_PACKAGES_DIR}/lib/LightPcapNg.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/LightPcapNg.lib"
    )
else()
    if(VCPKG_TARGET_IS_LINUX)
        set(CONFIG_CMD "configure-linux.sh --default")
    elseif(VCPKG_TARGET_IS_OSX)
        set(CONFIG_CMD "configure-mac_os_x.sh")
    else()
        message(FATAL_ERROR "Unsupported platform")
    endif()

    vcpkg_execute_required_process(
        COMMAND ${CONFIG_CMD}
        WORKING_DIRECTORY ${SOURCE_PATH}
    )

    vcpkg_build_make(BUILD_TARGET libs)

    # Include
    file(
        INSTALL ${SOURCE_PATH}/Dist/header/*.h
        DESTINATION ${CURRENT_PACKAGES_DIR}/include
    )

    # Copyright
    file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pcapplusplus RENAME copyright)
endif()

# file(GLOB LIB_DEBUG_FILES "${SOURCE_PATH}/Dist/header/Win32/Debug/*")
# file(GLOB LIB_RELEASE_FILES "${SOURCE_PATH}/Dist/header/Win32/Release/*.lib")
# file(
#     COPY ${LIB_DEBUG_FILES}
#     DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
# )
# file(
#     COPY ${LIB_RELEASE_FILES}
#     DESTINATION ${CURRENT_PACKAGES_DIR}/lib
# )
# vcpkg_install_msbuild(
#     SOURCE_PATH "${SOURCE_PATH}"
#     PROJECT_SUBPATH "mk/${VS_VERSION}/Packet++.vcxproj"
#     PLATFORM ${TRIPLET_SYSTEM_ARCH}
#     USE_VCPKG_INTEGRATION
# )
# vcpkg_install_msbuild(
#     SOURCE_PATH "${SOURCE_PATH}"
#     PROJECT_SUBPATH "mk/${VS_VERSION}/Pcap++.vcxproj"
#     PLATFORM ${TRIPLET_SYSTEM_ARCH}
#     USE_VCPKG_INTEGRATION
# )

# # Include
# file(
#     INSTALL ${SOURCE_PATH}/Dist/header/*.h
#     DESTINATION ${CURRENT_PACKAGES_DIR}/include/pcapplusplus
# )

# # Copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pcapplusplus RENAME copyright)

# if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
#   set(ENABLE_PCAP TRUE)
# endif()

# vcpkg_configure_cmake(
#     SOURCE_PATH ${SOURCE_PATH}
#     PREFER_NINJA
#     OPTIONS
#         -DLIBTINS_BUILD_SHARED=${LIBTINS_BUILD_SHARED}
#         -DLIBTINS_ENABLE_PCAP=${ENABLE_PCAP}
#         -DLIBTINS_ENABLE_CXX11=1
# )

# vcpkg_install_cmake()

# if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "windows" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore") #Windows
#     vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
# else() #Linux/Unix/Darwin
#     vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libtins)
# endif()

# file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# # Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libtins RENAME copyright)
