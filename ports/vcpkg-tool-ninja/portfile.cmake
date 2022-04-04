set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(program NINJA)
set(program_version 1.10.2)
set(program_name "ninja")
set(search_names "ninja")
set(apt_package_name "ninja-build")
set(brew_package_name "ninja-build")
set(paths_to_search "${CURRENT_PACKAGES_DIR}/tools/ninja")
set(supported_on_unix ON)
set(version_command --version)
set(extra_search_args EXACT_VERSION_MATCH)

if(NOT "${program}")
    vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ninja-build/ninja
    REF 170c387a7461d476523ae29c115a58f16e4d3430
    SHA512 75c0f263ad325d14c99c9a1d85e571832407b481271a2733e78183a478f7ecd22d84451fc8d7ce16ab20d641ce040761d7ab266695d66bbac5b2b9a3a29aa521
    HEAD_REF master
    PATCHES PR2056.diff # Long path support windows
)
    # This copied from vcpkg_configure_cmake to find a generator which is not ninja!
    set(generator_arch "")
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        if("${VCPKG_PLATFORM_TOOLSET}" STREQUAL "v120" AND NOT "${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "arm64")
            set(generator "Visual Studio 12 2013")
        elseif("${VCPKG_PLATFORM_TOOLSET}" STREQUAL "v140" AND NOT "${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "arm64")
            set(generator "Visual Studio 14 2015")
        elseif("${VCPKG_PLATFORM_TOOLSET}" STREQUAL "v141")
            set(generator "Visual Studio 15 2017")
        elseif("${VCPKG_PLATFORM_TOOLSET}" STREQUAL "v142")
            set(generator "Visual Studio 16 2019")
        elseif("${VCPKG_PLATFORM_TOOLSET}" STREQUAL "v143")
            set(generator "Visual Studio 17 2022")
        endif()

        if("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x86")
            set(generator_arch "Win32")
        elseif("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x64")
            set(generator_arch "x64")
        elseif("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "arm")
            set(generator_arch "ARM")
        elseif("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "arm64")
            set(generator_arch "ARM64")
        endif()
        if("${generator}" STREQUAL "" OR "${generator_arch}" STREQUAL "")
            message(FATAL_ERROR
                "Unable to determine appropriate generator for triplet ${TARGET_TRIPLET}:
    platform toolset: ${VCPKG_PLATFORM_TOOLSET}
    architecture    : ${VCPKG_TARGET_ARCHITECTURE}")
        endif()
        vcpkg_list(APPEND cmake_options "-DBUILD_UNICODE:BOOL=ON")
    else()
        set(generator "Unix Makefiles")
    endif()
    if(NOT "${generator_arch}" STREQUAL "")
        vcpkg_list(APPEND cmake_options "-A${generator_arch}")
    endif()

    set(VCPKG_BUILD_TYPE release) #we only need release here!
    vcpkg_configure_cmake(
        DISABLE_PARALLEL_CONFIGURE
        SOURCE_PATH "${SOURCE_PATH}"
        GENERATOR "${generator}"
        OPTIONS ${cmake_options}
        )
    vcpkg_install_cmake()
    set(PORT ninja) # to trick vcpkg_copy_tools
    vcpkg_copy_tools(TOOL_NAMES ninja AUTO_CLEAN)
    set(PORT vcpkg-tool-ninja)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)
endif()

z_vcpkg_find_acquire_program_find_internal("${program}"
    INTERPRETER "${interpreter}"
    PATHS ${paths_to_search}
    NAMES ${search_names}
)
message(STATUS "Using ninja: ${NINJA}")

