vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeRDP/FreeRDP
    REF "${VERSION}"
    SHA512 722d95d7591b5ce6a7e8a3b6ac8999df278dbcfc286a532f56bcbc4a3881e75b02c7e3cd4b296e67bc19d1165020acdcca198bf4bcc92aea5611760037fcc57f
    HEAD_REF master
    PATCHES
        DontInstallSystemRuntimeLibs.patch
        fix-include-path.patch
        fix-install-destination.patch
        keep-dup-libs.patch
        wfreerdp-server-cli.patch
        pr-7060-jni-onload.patch
        find-dependency.patch
        export-include.patch
)
file(REMOVE "${SOURCE_PATH}/cmake/FindOpenSSL.cmake")
file(WRITE "${SOURCE_PATH}/.source_version" "${VERSION}-vcpkg")

if("x11" IN_LIST FEATURES)
    message(STATUS "${PORT} currently requires the following libraries from the system package manager:\n    libxfixes-dev\n")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        client-mac WITH_CLIENT_MAC
        ffmpeg  WITH_FFMPEG
        ffmpeg  WITH_SWSCALE
        server  WITH_SERVER
    	urbdrc  CHANNEL_URBDRC
        wayland WITH_WAYLAND
        winpr-tools WITH_WINPR_TOOLS
        x11     WITH_X11
)

vcpkg_list(SET GENERATOR_OPTION)
if(VCPKG_TARGET_IS_OSX)
    list(APPEND GENERATOR_OPTION GENERATOR "Unix Makefiles")
endif()

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    ${GENERATOR_OPTION}
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DWITH_CCACHE=OFF
        -DWITH_CLANG_FORMAT=OFF
        -DWITH_MANPAGES=OFF
        -DWITH_OPENSSL=ON
        "-DMSVC_RUNTIME=${VCPKG_CRT_LINKAGE}"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=ON
        # Uncontrolled dependencies w.r.t. vcpkg ports
        # Can be overriden in custom triplet file
        -DWITH_ALSA=OFF
        -DWITH_CAIRO=OFF
    MAYBE_UNUSED_VARIABLES
        MSVC_RUNTIME
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_list(SET tools)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND tools wfreerdp)
    if("server" IN_LIST FEATURES)
        list(APPEND tools wfreerdp-server)
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    if("client-mac" IN_LIST FEATURES)
        file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/client/Mac/cli/MacFreeRDP.app"
            DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
        )
        list(APPEND tools MacFreeRDP)
    endif()
    if("server" IN_LIST FEATURES)
        list(APPEND tools mfreerdp-server)
    endif()
endif()
if("wayland" IN_LIST FEATURES)
    list(APPEND tools wlfreerdp)
endif()
if("x11" IN_LIST FEATURES)
    list(APPEND tools xfreerdp)
endif()
if("winpr-tools" IN_LIST FEATURES)
    list(APPEND tools winpr-hash winpr-makecert)
endif()
if("server" IN_LIST FEATURES)
    list(APPEND tools freerdp-proxy freerdp-shadow-cli)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP-Server2 PACKAGE_NAME freerdp-server2 DO_NOT_DELETE_PARENT_CONFIG_PATH)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP-Shadow2 PACKAGE_NAME freerdp-shadow2 DO_NOT_DELETE_PARENT_CONFIG_PATH)
endif()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP-Client2 PACKAGE_NAME freerdp-client2 DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/WinPR2 PACKAGE_NAME winpr2 DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP2 PACKAGE_NAME freerdp)

if(tools)
    vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/freerdp/build-config.h" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel" ".")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/freerdp/build-config.h" "${CURRENT_PACKAGES_DIR}/" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/freerdp/build-config.h" "${CURRENT_PACKAGES_DIR}" "")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
