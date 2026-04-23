vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sqlcipher/sqlcipher
    REF "v${VERSION}"
    SHA512 023b2fc7248fe38b758ef93dd8436677ff0f5d08b1061e7eab0adb9e38ad92d523e0ab69016ee69bd35c1fd53c10f61e99b01f7a2987a1f1d492e1f7216a0a9c
    HEAD_REF master
)

# Don't use vcpkg_build_nmake, because it doesn't handle nmake targets correctly.
find_program(NMAKE nmake REQUIRED)

# Find tclsh Executable needed for Amalgamation of SQLite
if(NOT TARGET_TRIPLET STREQUAL HOST_TRIPLET)
    set(TCL_TOOLS_DIR "${CURRENT_HOST_INSTALLED_DIR}/tools/tcl/bin")
else()
    set(TCL_TOOLS_DIR "${CURRENT_INSTALLED_DIR}/tools/tcl/bin")
endif()

file(GLOB TCLSH_CMD
    "${TCL_TOOLS_DIR}/tclsh*${VCPKG_HOST_EXECUTABLE_SUFFIX}"
)
if(TCLSH_CMD STREQUAL "")
    message(FATAL_ERROR "Unable to find tclsh in ${TCL_TOOLS_DIR}")
endif()
list(SORT TCLSH_CMD)
list(GET TCLSH_CMD 0 TCLSH_CMD)
file(TO_NATIVE_PATH "${TCLSH_CMD}" TCLSH_CMD)

# Determine TCL version (e.g. [path]tclsh90sx.exe -> 90)
string(REGEX REPLACE ^.*tclsh "" TCLVERSION ${TCLSH_CMD})
string(REGEX REPLACE [A-Za-z]*${VCPKG_HOST_EXECUTABLE_SUFFIX}$ "" TCLVERSION ${TCLVERSION})

list(APPEND NMAKE_OPTIONS
    TCLSH_CMD="${TCLSH_CMD}"
    TCLVERSION=${TCLVERSION}
    EXT_FEATURE_FLAGS=-DSQLITE_TEMP_STORE=2\ -DSQLITE_HAS_CODEC
)
if(NOT TARGET_TRIPLET STREQUAL HOST_TRIPLET)
    # Ask upstream Makefile.msc to build helper tools (for example lemon.exe)
    # using host compiler/linker settings during cross-compilation.
    list(APPEND NMAKE_OPTIONS
        XCOMPILE=1
        USE_NATIVE_LIBPATHS=1
    )
endif()

set(ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include;$ENV{INCLUDE}")

# Creating amalgamation files
message(STATUS "Pre-building ${TARGET_TRIPLET}")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f Makefile.msc /A /NOLOGO clean sqlite3.c
    ${NMAKE_OPTIONS}
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME pre-build-${TARGET_TRIPLET}
)
message(STATUS "Pre-building ${TARGET_TRIPLET} done")

# The rest of the build process with the CMakeLists.txt is merely a copy of sqlite3

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        geopoly WITH_GEOPOLY
        json1 WITH_JSON1
        fts5 WITH_FTS5
    INVERTED_FEATURES
        tool SQLITE3_SKIP_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSQLCIPHER_VERSION=${VERSION}
    OPTIONS_DEBUG
        -DSQLITE3_SKIP_TOOLS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH share/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(NOT SQLITE3_SKIP_TOOLS AND EXISTS "${CURRENT_PACKAGES_DIR}/tools/${PORT}/sqlcipher-bin${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/${PORT}/sqlcipher-bin${VCPKG_HOST_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/sqlcipher${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/sqlcipher-config.in.cmake"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/sqlcipher-config.cmake"
    @ONLY
)

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
vcpkg_fixup_pkgconfig()
