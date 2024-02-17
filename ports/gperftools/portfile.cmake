vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gperftools/gperftools
    REF gperftools-2.10
    SHA512 4400711723be9401f519d85b3b69c026e4715473cbed48ab0573df17abdf895fb971ee969875fe5127a2e8b9aba90d858285e50c8e012384c2c36d5a76b1f0c4
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

    if(override IN_LIST FEATURES)
        if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
            message(STATUS "${PORT}[override] only supports static library linkage. Building static library.")
            vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)
        endif()
    endif()

    vcpkg_check_features(
        OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        FEATURES
            override GPERFTOOLS_WIN32_OVERRIDE
            tools GPERFTOOLS_BUILD_TOOLS
    )

    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        DISABLE_PARALLEL_CONFIGURE
        OPTIONS
            ${FEATURE_OPTIONS}
    )

    vcpkg_cmake_install()

    vcpkg_copy_pdbs()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(GLOB gperf_public_headers "${CURRENT_PACKAGES_DIR}/include/gperftools/*.h")

        foreach(gperf_header ${gperf_public_headers})
            vcpkg_replace_string(${gperf_header} "__declspec(dllimport)" "")
        endforeach()
    endif()

    if(tools IN_LIST FEATURES)
        vcpkg_copy_tools(TOOL_NAMES addr2line-pdb nm-pdb AUTO_CLEAN)
    endif()
else()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(BUILD_OPTS --enable-shared --disable-static)
    else()
        set(BUILD_OPTS --enable-static --disable-shared)
    endif()

    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        AUTOCONFIG
        OPTIONS
            ${BUILD_OPTS}
    )

    vcpkg_install_make()

    if(tools IN_LIST FEATURES)
        vcpkg_copy_tools(TOOL_NAMES pprof pprof-symbolize AUTO_CLEAN)
    endif()

    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/include"
        "${CURRENT_PACKAGES_DIR}/debug/share"
    )

    # https://github.com/microsoft/vcpkg/pull/8750#issuecomment-625590773
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()

    vcpkg_fixup_pkgconfig()
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
