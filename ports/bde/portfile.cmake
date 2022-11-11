vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
set(CONFIGURE_COMMON_ARGS ${CONFIGURE_COMMON_ARGS} --library-type=static)

set(BDE_VERSION 3.2.0.0)
set(BDE_TOOLS_VERSION 1.x)

# Paths used in build
set(SOURCE_PATH_DEBUG ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bde-${BDE_VERSION})
set(SOURCE_PATH_RELEASE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bde-${BDE_VERSION})

# Acquire Python 2 and add it to PATH
vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_EXE_PATH ${PYTHON2} DIRECTORY)

# Acquire BDE Tools and add them to PATH
vcpkg_from_github(
    OUT_SOURCE_PATH TOOLS_PATH
    REPO "bloomberg/bde-tools"
    REF d4b1a7670829228f4ec81ecdccc598ce03ae8e80
    SHA512 80af734c080adb225d5369157301ae0af18e02b1912351e34d23f5f2ba4e19f9ae2b5a367923f036330c9f9afd11a90cdf12680eb3e59b4297a312a1b713f17f
    HEAD_REF master
)
message(STATUS "Configure bde-tools-v${BDE_TOOLS_VERSION}")
if(VCPKG_CMAKE_SYSTEM_NAME)
    set(ENV{PATH} "$ENV{PATH}:${PYTHON2_EXE_PATH}")
    set(ENV{PATH} "$ENV{PATH}:${TOOLS_PATH}/bin")
else()
    set(ENV{PATH} "$ENV{PATH};${PYTHON2_EXE_PATH}")
    set(ENV{PATH} "$ENV{PATH};${TOOLS_PATH}/bin")
endif()

# Acquire BDE sources
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "bloomberg/bde"
    REF 3720d132d0879f19b9084cca62ebc75f1f24e1a3
    SHA512 234ebb71997f5b7d3951584235ead10f977689cef323ae1c198629a6b1995b1481d8a1515d827c46df10209bdc66e1f3cc7780dafee9ca0ff4172be47c460d78
    HEAD_REF master
)

# Clean up previous builds
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
                    ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

# Identify waf executable and calculate configure args
if(VCPKG_CMAKE_SYSTEM_NAME)
    set(WAF_COMMAND waf)
else()
    set(WAF_COMMAND waf.bat)
endif()
set(CONFIGURE_COMMON_ARGS ${CONFIGURE_COMMON_ARGS} --use-flat-include-dir)
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(CONFIGURE_COMMON_ARGS ${CONFIGURE_COMMON_ARGS} --abi-bits=32)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CONFIGURE_COMMON_ARGS ${CONFIGURE_COMMON_ARGS} --abi-bits=64)
else()
    message(FATAL_ERROR "Unsupported target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    set(CONFIGURE_COMMON_ARGS ${CONFIGURE_COMMON_ARGS} --msvc-runtime-type=static)
else()
    set(ENV{CFLAGS} "$ENV{CFLAGS} -Wno-error=implicit-function-declaration")
endif()

# Configure debug
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${WAF_COMMAND} configure ${CONFIGURE_COMMON_ARGS}
            --prefix=${CURRENT_PACKAGES_DIR}/debug --out=${SOURCE_PATH_DEBUG}
            --build-type=debug
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME configure-${TARGET_TRIPLET}--dbg
)
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")

# Build debug
message(STATUS "Building ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${WAF_COMMAND} build
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}--dbg
)
message(STATUS "Building ${TARGET_TRIPLET}-dbg done")

# Install debug
message(STATUS "Installing ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${WAF_COMMAND} install
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME install-${TARGET_TRIPLET}--dbg
)
# Include files should not be duplicated
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# pkg-config files should point to correct include directory
file(GLOB PC_FILES "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*.pc")
foreach(PC_FILE_NAME ${PC_FILES})
    file(READ "${PC_FILE_NAME}" _contents)
    string(REPLACE "includedir=\${prefix}/include" "includedir=\${prefix}/../include" _contents "${_contents}")
    file(WRITE "${PC_FILE_NAME}" "${_contents}")
endforeach()
message(STATUS "Installing ${TARGET_TRIPLET}-dbg done")

# Configure release
message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${WAF_COMMAND} configure ${CONFIGURE_COMMON_ARGS}
            --prefix=${CURRENT_PACKAGES_DIR} --out=${SOURCE_PATH_RELEASE}
            --build-type=release
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME configure-${TARGET_TRIPLET}--rel
)
message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")

# Build release
message(STATUS "Building ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${WAF_COMMAND} build
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}--rel
)
message(STATUS "Building ${TARGET_TRIPLET}-rel done")

# Install release
message(STATUS "Installing ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${WAF_COMMAND} install
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME install-${TARGET_TRIPLET}--rel
)
message(STATUS "Installing ${TARGET_TRIPLET}-rel done")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/bde
     RENAME copyright
)

vcpkg_fixup_pkgconfig()
