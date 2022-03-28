if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO ShiftMediaProject/nettle
        REF bf483378326c67d634977287dd576279734b7acc #v3.6
        SHA512 ba125a27c81a800be8bc8d1b0d4f3125587330ef64d8a605b4d3ae211fb675c5ef89e9bf4bcf63b07d0f004c6c5ff851630690cdd1eda6b5b8a526d84edffe73
        HEAD_REF master
        PATCHES
            gmp.patch
            name.dir.patch
            runtime.patch
            remove_gmpd.patch
    )

    include(${CURRENT_INSTALLED_DIR}/share/yasm-tool-helper/yasm-tool-helper.cmake)
    yasm_tool_helper(OUT_VAR YASM)
    file(TO_NATIVE_PATH "${YASM}" YASM)

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(CONFIGURATION_RELEASE ReleaseDLL)
        set(CONFIGURATION_DEBUG DebugDLL)
    else()
        set(CONFIGURATION_RELEASE Release)
        set(CONFIGURATION_DEBUG Debug)
    endif()

    if(VCPKG_TARGET_IS_UWP)
        string(APPEND CONFIGURATION_RELEASE WinRT)
        string(APPEND CONFIGURATION_DEBUG WinRT)
    endif()

    #Setup YASM integration
    set(_nettleproject)
    set(_hogweedproject)
    if(VCPKG_TARGET_IS_UWP)
        set(_nettleproject "${SOURCE_PATH}/SMP/libnettle_winrt.vcxproj")
        set(_hogweedproject "${SOURCE_PATH}/SMP/libhogweed_winrt.vcxproj")
    else()
        set(_nettleproject "${SOURCE_PATH}/SMP/libnettle.vcxproj")
        set(_hogweedproject "${SOURCE_PATH}/SMP/libhogweed.vcxproj")
    endif()

    file(READ "${_nettleproject}" _contents)
    string(REPLACE  [[<Import Project="$(VCTargetsPath)\BuildCustomizations\yasm.props" />]]
                     "<Import Project=\"${CURRENT_INSTALLED_DIR}/share/vs-yasm/yasm.props\" />"
                    _contents "${_contents}")
    string(REPLACE  [[<Import Project="$(VCTargetsPath)\BuildCustomizations\yasm.targets" />]]
                     "<Import Project=\"${CURRENT_INSTALLED_DIR}/share/vs-yasm/yasm.targets\" />"
                    _contents "${_contents}")
    string(REGEX REPLACE "${VCPKG_ROOT_DIR}/installed/[^/]+/share" "${CURRENT_INSTALLED_DIR}/share" _contents "${_contents}") # Above already
    file(WRITE "${_nettleproject}" "${_contents}")

    file(READ "${_hogweedproject}" _contents)
    string(REPLACE  [[<Import Project="$(VCTargetsPath)\BuildCustomizations\yasm.props" />]]
                     "<Import Project=\"${CURRENT_INSTALLED_DIR}/share/vs-yasm/yasm.props\" />"
                    _contents "${_contents}")
    string(REPLACE  [[<Import Project="$(VCTargetsPath)\BuildCustomizations\yasm.targets" />]]
                     "<Import Project=\"${CURRENT_INSTALLED_DIR}/share/vs-yasm/yasm.targets\" />"
                    _contents "${_contents}")
    string(REGEX REPLACE "${VCPKG_ROOT_DIR}/installed/[^/]+/share" "${CURRENT_INSTALLED_DIR}/share" _contents "${_contents}") # Above already
    file(WRITE "${_hogweedproject}" "${_contents}")

    vcpkg_install_msbuild(
        USE_VCPKG_INTEGRATION
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH SMP/libnettle.sln
        PLATFORM ${TRIPLET_SYSTEM_ARCH}
        LICENSE_SUBPATH COPYING.LESSERv3
        TARGET Rebuild
        RELEASE_CONFIGURATION ${CONFIGURATION_RELEASE}
        DEBUG_CONFIGURATION ${CONFIGURATION_DEBUG}
        SKIP_CLEAN
        OPTIONS "/p:YasmPath=${YASM}"
    )

    get_filename_component(SOURCE_PATH_SUFFIX "${SOURCE_PATH}" NAME)
    file(RENAME "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${SOURCE_PATH_SUFFIX}/msvc/include" "${CURRENT_PACKAGES_DIR}/include")
    set(PACKAGE_VERSION 3.6)
    set(prefix "${CURRENT_INSTALLED_DIR}")
    set(exec_prefix "\${prefix}")
    set(libdir "\${prefix}/lib")
    set(includedir "\${prefix}/include")
    set(LIBS "-lnettle -lgmp")
    configure_file("${SOURCE_PATH}/nettle.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/nettle.pc" @ONLY)
    set(HOGWEED -lhogweed)
    set(LIBS -lnettle)
    configure_file("${SOURCE_PATH}/hogweed.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libhogweed.pc" @ONLY)
    set(prefix "${CURRENT_INSTALLED_DIR}/debug")
    set(exec_prefix "\${prefix}")
    set(libdir "\${prefix}/lib")
    set(includedir "\${prefix}/../include")
    set(LIBS "-lnettled -lgmp")
    configure_file("${SOURCE_PATH}/nettle.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/nettle.pc" @ONLY)
    set(LIBS -lnettled)
    set(HOGWEED -lhogweedd)
    configure_file("${SOURCE_PATH}/hogweed.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libhogweed.pc" @ONLY)
    vcpkg_fixup_pkgconfig()
else()
    vcpkg_from_gitlab(
        GITLAB_URL https://git.lysator.liu.se/
        OUT_SOURCE_PATH SOURCE_PATH
        REPO nettle/nettle
        REF  9e2bea82b9fb606bffd2d3f648e05248e146e54f #v3.6
        SHA512 008089eba2ef197a0ec6a266baac485e72051e646d19861f3fb605915a591bc2dd38edcb4ea7eaad958ea5d56f7744d42c25b691b49921a1285edd22f9c90b7f
        HEAD_REF master
        PATCHES 
		fix-InstallLibPath.patch
		flags.patch
    )

    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(OPTIONS --disable-static)
    else()
        set(OPTIONS --disable-shared)
    endif()

    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        AUTOCONFIG
        OPTIONS
            --disable-documentation
            --disable-openssl
            ${OPTIONS}
    )

    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

    # # Handle copyright
    file(INSTALL "${SOURCE_PATH}/COPYINGv3" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR VCPKG_TARGET_IS_LINUX)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
endif()
