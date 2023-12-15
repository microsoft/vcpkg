set(extra_patches "")
if (VCPKG_TARGET_IS_OSX)
	list(APPEND extra_patches 005-do-not-pass-ld-e-macosx.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LuaJIT/LuaJIT
    REF 29b0b282f59ac533313199f4f7be79490b7eee51  #2023-12-11
    SHA512 47cd30427740220fbb541d1f052acf7f265fef3d504cd8c2b8a595243a9392fddb84cd3106c54055da316ab260a26eb59ca93a928bbc6296a875d37969e19de8
    HEAD_REF master
    PATCHES
        msvcbuild.patch
        003-do-not-set-macosx-deployment-target.patch
        ${extra_patches}
)

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

if(VCPKG_DETECTED_MSVC)
    # Due to lack of better MSVC cross-build support, just always build the host
    # minilua tool with the target toolchain. This will work for native builds and
    # for targeting x86 from x64 hosts. (UWP and ARM64 is unsupported.)
    vcpkg_list(SET options)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND options "MSVCBUILD_OPTIONS=static")
    endif()

    vcpkg_install_nmake(SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_NAME "${CMAKE_CURRENT_LIST_DIR}/Makefile.nmake"
        OPTIONS
            ${options}
    )

    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/luajit/luaconf.h" "defined(LUA_BUILD_AS_DLL)" "1")
    endif()

    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/luajit.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
    if(NOT VCPKG_BUILD_TYPE)
        file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/luajit.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    endif()

    vcpkg_copy_pdbs()
else()
    vcpkg_list(SET options)
    if(VCPKG_CROSSCOMPILING)
        list(APPEND options
            "LJARCH=${VCPKG_TARGET_ARCHITECTURE}"
            "BUILDVM_X=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/buildvm-${VCPKG_TARGET_ARCHITECTURE}${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        )
    endif()

    vcpkg_list(SET make_options "EXECUTABLE_SUFFIX=${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    set(strip_options "") # cf. src/Makefile
    if(VCPKG_TARGET_IS_OSX)
        vcpkg_list(APPEND make_options "TARGET_SYS=Darwin")
        set(strip_options " -x")
    elseif(VCPKG_TARGET_IS_IOS)
        vcpkg_list(APPEND make_options "TARGET_SYS=iOS")
        set(strip_options " -x")
    elseif(VCPKG_TARGET_IS_LINUX)
        vcpkg_list(APPEND make_options "TARGET_SYS=Linux")
    elseif(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_list(APPEND make_options "TARGET_SYS=Windows")
        set(strip_options " --strip-unneeded")
    endif()

    set(dasm_archs "")
    if("buildvm-32" IN_LIST FEATURES)
        string(APPEND dasm_archs " arm x86")
    endif()
    if("buildvm-64" IN_LIST FEATURES)
        string(APPEND dasm_archs " arm64 x64")
    endif()

    file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}")
    vcpkg_configure_make(SOURCE_PATH "${SOURCE_PATH}"
        COPY_SOURCE
        OPTIONS
            "BUILDMODE=${VCPKG_LIBRARY_LINKAGE}"
            ${options}
        OPTIONS_RELEASE
            "DASM_ARCHS=${dasm_archs}"
    )
    vcpkg_install_make(
        MAKEFILE "Makefile.vcpkg"
        OPTIONS
            ${make_options}
            "TARGET_AR=${VCPKG_DETECTED_CMAKE_AR} rcus"
            "TARGET_STRIP=${VCPKG_DETECTED_CMAKE_STRIP}${strip_options}"
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/lua"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/lib/lua"
    "${CURRENT_PACKAGES_DIR}/share/lua"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

if (NOT VCPKG_TARGET_IS_OSX)
    vcpkg_copy_tools(TOOL_NAMES luajit AUTO_CLEAN)
endif()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
