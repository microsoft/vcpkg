vcpkg_fail_port_install(ON_TARGET "OSX" "UWP")
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs952/ghostscript-9.52.tar.gz"
    FILENAME "ghostscript-9.52.tar.gz"
    SHA512 32fb2a3d4e81ac9e281202aaed2f7811e80c939cbce3ffef7ec7cf78213e5da8a2f6c13d15f0c6c8fd24566579ba8b69364d4c66f4e4b7851f6df9209d0ff046
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        0001-Add-ARM-definition.patch
        0002-Fix-ARM-build.patch
        0003-Add-ARM-support-in-tools.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        set(ARCH_CONFIG )
        set(FILE_ARCH 32)
    elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
        set(ARCH_CONFIG WIN64=1)
        set(FILE_ARCH 64)
    elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
        set(ARCH_CONFIG ARM=1)
        set(FILE_ARCH ARM32)
    elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)
        set(ARCH_CONFIG WIN64=1 ARM=1)
        set(FILE_ARCH ARM64)
    endif()

    if (VCPKG_PLATFORM_TOOLSET MATCHES "v140")
        set(VCVER 14)
    elseif (VCPKG_PLATFORM_TOOLSET MATCHES "v141")
        set(VCVER 15)
    elseif (VCPKG_PLATFORM_TOOLSET MATCHES "v142")
        set(VCVER 16)
    endif()

    vcpkg_get_windows_sdk(VCPKG_TARGET_PLATFORM_VERSION)
    file(TO_CMAKE_PATH "$ENV{VCToolsInstallDir}" VCTOOLSDIR)

    set(CONFIG
            ${ARCH_CONFIG}
            MSVC_VERSION=${VCVER}
            DEVSTUDIO=${VCTOOLSDIR}
            WINSDKVER=${VCPKG_TARGET_PLATFORM_VERSION}
    )

    vcpkg_build_nmake(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_NAME "psi/msvc32.mak"
        OPTIONS_RELEASE
            ${CONFIG}
            DEBUGSYM=1
        OPTIONS_DEBUG
            ${CONFIG}
            DEBUG=1
            TDEBUG=1
    )

    file(INSTALL
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/profbin/gsdll${FILE_ARCH}.dll
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/profbin/gsdll${FILE_ARCH}.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )

    file(INSTALL
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/profbin/gsdll${FILE_ARCH}.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )

    file(INSTALL
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/debugbin/gsdll${FILE_ARCH}.dll
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/debugbin/gsdll${FILE_ARCH}.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )

    file(INSTALL
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/debugbin/gsdll${FILE_ARCH}.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    
    file(GLOB RELEASE_TOOLS
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/profbin/*.dll
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/profbin/*.exe
    )
    file(INSTALL
        ${RELEASE_TOOLS}
        DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}
    )

    file(GLOB DEBUG_TOOLS
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/debugbin/*.dll
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/debugbin/*.exe
    )
    file(INSTALL
        ${DEBUG_TOOLS}
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}
    )

    file(INSTALL
        ${SOURCE_PATH}/psi/ierrors.h
        ${SOURCE_PATH}/psi/iapi.h
        ${SOURCE_PATH}/devices/gdevdsp.h
        ${SOURCE_PATH}/base/gserrors.h
        DESTINATION ${CURRENT_PACKAGES_DIR}/include
    )
else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        AUTOCONFIG
    )
    
    find_program(MAKE make REQUIRED)
    
    foreach(BUILDTYPE "debug" "release")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)
            if(BUILDTYPE STREQUAL "debug")
                set(SHORT_BUILDTYPE "-dbg")
            else()
                set(SHORT_BUILDTYPE "-rel")
            endif()

            set(WORKING_DIRECTORY
                    ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${SHORT_BUILDTYPE})

            message(STATUS "Building ${TARGET_TRIPLET}${SHORT_BUILDTYPE}")
            vcpkg_execute_build_process(
                COMMAND make so -j ${VCPKG_CONCURRENCY}
                WORKING_DIRECTORY ${WORKING_DIRECTORY}
                LOGNAME "build-${TARGET_TRIPLET}${SHORT_BUILDTYPE}"
            )

            message(STATUS "Installing ${TARGET_TRIPLET}${SHORT_BUILDTYPE}")
            vcpkg_execute_build_process(
                COMMAND make soinstall
                WORKING_DIRECTORY ${WORKING_DIRECTORY}
                LOGNAME "install-${TARGET_TRIPLET}${SHORT_BUILDTYPE}"
            )
        endif()
    endforeach()

    vcpkg_fixup_pkgconfig()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ghostscript RENAME copyright)
