# We currently insist on static only because:
# - Thrift doesn't yet support building as a DLL on Windows,
# - x64-linux only builds static anyway.
# From https://github.com/apache/thrift/blob/master/CHANGES.md
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/thrift
    REF cecee50308fc7e6f77f55b3fd906c1c6c471fa2f #0.13.0
    SHA512 4097fd7951a4d47f2fadc520a54fd1b91b10769d65e899c6bab490dd7ac459e12bb2aa335df8fdfc61a32095033bfac928a54660abb1ee54ca14a144216c3339
    HEAD_REF master
    PATCHES
      "correct-paths.patch"
)

if (VCPKG_TARGET_IS_OSX)
    message(WARNING "${PORT} requires bison version greater than 2.5,\n\
please use command \`brew install bison\` to install bison")
endif()

# note we specify values for WITH_STATIC_LIB and WITH_SHARED_LIB because even though
# they're marked as deprecated, Thrift incorrectly hard-codes a value for BUILD_SHARED_LIBS.
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    NO_CHARSET_FLAG
    OPTIONS
        -DWITH_SHARED_LIB=off
        -DWITH_STATIC_LIB=on
        -DWITH_STDTHREADS=ON
        -DBUILD_TESTING=off
        -DBUILD_JAVA=off
        -DBUILD_C_GLIB=off
        -DBUILD_PYTHON=off
        -DBUILD_CPP=on
        -DBUILD_HASKELL=off
        -DBUILD_TUTORIALS=off
        -DFLEX_EXECUTABLE=${FLEX}
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt5=TRUE
        -DBISON_EXECUTABLE=${BISON}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Move CMake config files to the right place
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/thrift)

file(GLOB COMPILER "${CURRENT_PACKAGES_DIR}/bin/thrift" "${CURRENT_PACKAGES_DIR}/bin/thrift.exe")
if(COMPILER)
    file(COPY ${COMPILER} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/thrift)
    file(REMOVE ${COMPILER})
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/thrift)
endif()

file(GLOB COMPILERD "${CURRENT_PACKAGES_DIR}/debug/bin/thrift" "${CURRENT_PACKAGES_DIR}/debug/bin/thrift.exe")
if(COMPILERD)
    file(REMOVE ${COMPILERD})
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if ("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
vcpkg_fixup_pkgconfig()
