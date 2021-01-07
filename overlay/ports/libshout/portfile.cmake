vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/Holzhaus/icecast-libshout.git
    REF 8a3d405ceda9d27f6f49871f566b685b1db4eff7
)

vcpkg_from_git(
    OUT_SOURCE_PATH COMMON_SOURCE_PATH
    URL https://github.com/Holzhaus/icecast-common.git
    REF cb1f0bd3e79d843545344a5369bebbd5640afcb7
)

file(COPY ${COMMON_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/src/common)

# Find cross-compiler prefix
if(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
endif()

if(CMAKE_C_COMPILER)
    vcpkg_execute_required_process(
        COMMAND ${CMAKE_C_COMPILER} -dumpmachine
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
        LOGNAME dumpmachine-${TARGET_TRIPLET}
    )
    file(READ ${CURRENT_BUILDTREES_DIR}/dumpmachine-${TARGET_TRIPLET}-out.log LIBSHOUT_HOST)
    string(REPLACE "\n" "" LIBSHOUT_HOST "${LIBSHOUT_HOST}")
    message(STATUS "Cross-compiling with ${CMAKE_C_COMPILER}")
    message(STATUS "Detected autoconf triplet --host=${LIBSHOUT_HOST}")
    message(STATUS "Options ${LIBSHOUT_OPTIONS}")
    set(LIBSHOUT_OPTIONS
        --host=${LIBSHOUT_HOST}
        ${LIBSHOUT_OPTIONS}
    )
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(LIBSHOUT_OPTIONS -DBUILD_SHARED_LIBS=ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${LIBSHOUT_OPTIONS}
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libshout RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
