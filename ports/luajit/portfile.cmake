vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LuaJIT/LuaJIT
    REF 707c12bf00dafdfd3899b1a6c36435dbbf6c7022  # 2026-01-09
    SHA512 c02b3600577936b9de04358fe03b3d995ee68e3416174c287022100aa0862b4e138c88e459b18a590dda7c08c1b6aded440bebfc80bbead2ae6b54cc4c82a2e9
    HEAD_REF master
    PATCHES
        msvcbuild.patch
        003-do-not-set-macosx-deployment-target.patch
)

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

if(VCPKG_DETECTED_MSVC)
    set(VSCMD_ARG_TGT_ARCH "${VCPKG_TARGET_ARCHITECTURE}")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
            set(host_arch $ENV{PROCESSOR_ARCHITEW6432})
        else()
            set(host_arch $ENV{PROCESSOR_ARCHITECTURE})
        endif()
        if(host_arch MATCHES "(amd|AMD)64")
            set(ENV{VSCMD_ARG_HOST_ARCH} "x64")
        endif()
    endif()

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

    # jit including the specific vmdef.lua generated during the build
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/jit" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/luajit/lua")

else()
    vcpkg_list(SET options)
    if(VCPKG_CROSSCOMPILING)
        list(APPEND options
            "LJARCH=${VCPKG_TARGET_ARCHITECTURE}"
            "BUILDVM_X=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/buildvm-${VCPKG_TARGET_ARCHITECTURE}${VCPKG_HOST_EXECUTABLE_SUFFIX}"
            "HOST_LUA=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/minilua${VCPKG_HOST_EXECUTABLE_SUFFIX}"
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

file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/luajit-symlink" "${CURRENT_PACKAGES_DIR}/debug/bin/luajit-symlink")
vcpkg_copy_tools(TOOL_NAMES luajit AUTO_CLEAN)

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
