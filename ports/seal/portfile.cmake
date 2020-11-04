if(NOT VCPKG_CMAKE_SYSTEM_NAME AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic") # Win32 and dynamic
    message(FATAL_ERROR "Only static linking is supported on Windows. Choose '*-windows-static' triplets.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SEAL
    REF b1ad0bcb745609741dccee1de96bb5bec69e4424
    SHA512 e80d0970f640f168252ec14dc33e7c88bd36220d5618dec45680b86114e7ce5af869628e95363ebfce9b07ea341ac7ef82493117a698d1065ac7f94baa9d3142
    HEAD_REF master
)

set(USE_MSGSL OFF)
set(USE_ZLIB OFF)
set(USE_ZSTD OFF)
if("ms-gsl" IN_LIST FEATURES)
    set(USE_MSGSL ON)
endif()
if("zlib" IN_LIST FEATURES)
    set(USE_ZLIB ON)
endif()
if("zstd" IN_LIST FEATURES)
    set(USE_ZSTD ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DALLOW_COMMAND_LINE_BUILD=ON
        -DSEAL_BUILD_DEPS=OFF
        -DSEAL_BUILD_EXAMPLES=OFF
        -DSEAL_BUILD_TESTS=OFF
        -DSEAL_BUILD_SEAL_C=OFF
        -DSEAL_USE_MSGSL=${USE_MSGSL}
        -DSEAL_USE_ZLIB=${USE_ZLIB}
        -DSEAL_USE_ZSTD=${USE_ZSTD}
)

vcpkg_build_cmake(TARGET seal LOGFILE_ROOT build)

vcpkg_install_cmake()

file(GLOB CONFIG_PATH RELATIVE "${CURRENT_PACKAGES_DIR}" "${CURRENT_PACKAGES_DIR}/lib/cmake/SEAL-*")
if(NOT CONFIG_PATH)
    message(FATAL_ERROR "Could not find installed cmake config files.")
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH "${CONFIG_PATH}")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
