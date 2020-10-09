vcpkg_fail_port_install(
    ON_ARCH "x86" "arm" "arm64"
    ON_TARGET "UWP")

# Patches may be provided at the end
function(checkout_in_path PATH URL REF SHA512)
    if(EXISTS "${PATH}")
        file(GLOB FILES "${PATH}")
        list(LENGTH FILES COUNT)
        if(COUNT GREATER 0)
            return()
        endif()
        file(REMOVE_RECURSE "${PATH}")
    endif()
    
    vcpkg_from_git(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        URL "${URL}"
        REF "${REF}"
        SHA512 "${SHA512}"
        PATCHES "${ARGN}"
    )
    file(RENAME "${DEP_SOURCE_PATH}" "${PATH}")
    file(REMOVE_RECURSE "${DEP_SOURCE_PATH}")
endfunction()

# Commits are based on https://chromium.googlesource.com/chromium/src/+/refs/tags/86.0.4199.1
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/25ce732")
file(MAKE_DIRECTORY "${SOURCE_PATH}/third_party")

set(CHROMIUM_GIT "https://chromium.googlesource.com/chromium/src")
checkout_in_path(
    "${SOURCE_PATH}/base"
    "${CHROMIUM_GIT}/base"
    "25ce73258703a5ac018da0e203fb3d4a98c2136e"
    "e6f135f0d6cdeefff6b4f848cb1cb41bcefa12a56bab034a751905fcef107f91a0c150767b2d1f5c81bd8f9242976e3c5967c19ffac89e14be782cf3d0f4f39d"
    res/0001-base.patch)
checkout_in_path(
    "${SOURCE_PATH}/build"
    "${CHROMIUM_GIT}/build"
    "312532ee66abdacbe58afb5df7ddf05e3a6399f9"
    "50b955151c10880032d07a998ac123b3182931c7bffd2aa69ae6b5939670c458f9d35530a09e0a237821de342b71b04c5c859c87ac0c7c8d5dd363d14bfd82a1"
    res/0002-build.patch)
checkout_in_path(
    "${SOURCE_PATH}/third_party/apple_apsl"
    "${CHROMIUM_GIT}/third_party/apple_apsl"
    "4cc25bbf65194f6726f7f10da0a885818e35d53e"
    "4eb1dc489379b4cfcea2533a40d3c38e7e6795b3314b323d91b0e9a4a9071b7073079ff930c9ff0ea4e8d1a8c8d9fe7091bdd4d2216bb4b0cc706653cd7c6c81")
checkout_in_path(
    "${SOURCE_PATH}/third_party/ced"
    "${CHROMIUM_GIT}/third_party/ced"
    "4cd87a44674edd9fe1f01c4cb5f1b73907ce4236"
    "684d75f0ecf87e704bc05a0808ec5b59eb27084470b4b7d39790fee92a163134b0ddbb3ce80069cf75ec2d3bf34e7cd0db7d67afc089593b3fb1dd547bdf007a")
checkout_in_path(
    "${SOURCE_PATH}/third_party/modp_b64"
    "${CHROMIUM_GIT}/third_party/modp_b64"
    "509f005fa65e652dc4a6f636da6fa1002b6dce16"
    "6fa37f7c2b53aff51caa76b0defeaaed5a949834ca5ead96bd625ce44137f8fa66dca499ccd52e3e87332028dd6a1d3c7c6772fe086bccfd3d89d81c500d714f")

set(RES "${CMAKE_CURRENT_LIST_DIR}/res")
file(COPY "${RES}/.gn" DESTINATION "${SOURCE_PATH}")
file(COPY "${RES}/BUILD.gn" DESTINATION "${SOURCE_PATH}")
file(COPY "${RES}/build_overrides" DESTINATION "${SOURCE_PATH}")
file(COPY "${RES}/testing" DESTINATION "${SOURCE_PATH}")
file(COPY "${RES}/tools" DESTINATION "${SOURCE_PATH}")
file(COPY "${RES}/gclient_args.gni" DESTINATION "${SOURCE_PATH}/build/config")
file(COPY "${RES}/LASTCHANGE.committime" DESTINATION "${SOURCE_PATH}/build/util")
file(COPY "${RES}/icu" DESTINATION "${SOURCE_PATH}/third_party")
file(COPY "${RES}/libxml" DESTINATION "${SOURCE_PATH}/third_party")
file(COPY "${RES}/protobuf" DESTINATION "${SOURCE_PATH}/third_party")
file(COPY "${RES}/fontconfig" DESTINATION "${SOURCE_PATH}/third_party")
file(COPY "${RES}/test_fonts" DESTINATION "${SOURCE_PATH}/third_party")

set(OPTIONS "\
    use_custom_libcxx=false \
    clang_use_chrome_plugins=false \
    forbid_non_component_debug_builds=false \
    treat_warnings_as_errors=false")
set(DEFINITIONS "")

if(WIN32)
    # Windows 10 SDK >= (10.0.19041.0) is required
    # https://developer.microsoft.com/en-us/windows/downloads/windows-10-sdk
    SET(VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK enabled)
    set(ENV{DEPOT_TOOLS_WIN_TOOLCHAIN} 0)
    set(OPTIONS "${OPTIONS} use_lld=false")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL Linux)
    set(OPTIONS "${OPTIONS} use_allocator=\"none\" use_sysroot=false use_glib=false")
endif()

# Find the directory that contains "bin/clang"
# Note: Only clang-cl is supported on Windows, see https://crbug.com/988071
vcpkg_find_acquire_program(CLANG)
if(CLANG MATCHES "-NOTFOUND")
    message(FATAL_ERROR "Clang is required.")
endif()
get_filename_component(CLANG "${CLANG}" DIRECTORY)
get_filename_component(CLANG "${CLANG}" DIRECTORY)
if((WIN32 AND NOT EXISTS "${CLANG}/bin/clang-cl.exe") OR 
   (APPLE AND NOT EXISTS "${CLANG}/bin/clang"))
    message(FATAL_ERROR "Clang needs to be inside a bin directory.")
endif()
set(OPTIONS "${OPTIONS} clang_base_path=\"${CLANG}\"")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OPTIONS "${OPTIONS} is_component_build=true")
    list(APPEND DEFINITIONS COMPONENT_BUILD)
else()
    set(OPTIONS "${OPTIONS} is_component_build=false")
endif()

if(APPLE)
    set(OPTIONS "${OPTIONS} enable_dsyms=true")
endif()

set(OPTIONS_DBG "${OPTIONS} is_debug=true symbol_level=2")
set(OPTIONS_REL "${OPTIONS} is_debug=false symbol_level=0")
set(DEFINITIONS_DBG ${DEFINITIONS})
set(DEFINITIONS_REL ${DEFINITIONS})

vcpkg_configure_gn(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG "${OPTIONS_DBG}"
    OPTIONS_RELEASE "${OPTIONS_REL}"
)

# Prevent a ninja re-config loop
set(NINJA_REBUILD "build build.ninja: gn\n  generator = 1\n  depfile = build.ninja.d")
vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/build.ninja" "${NINJA_REBUILD}" "")
vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/build.ninja" "${NINJA_REBUILD}" "")

set(TARGETS 
    base base:base_static
    base/third_party/dynamic_annotations 
    base/third_party/double_conversion)

if(WIN32)
    list(APPEND TARGETS base/win:pe_image)
endif()

vcpkg_install_gn(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS ${TARGETS}
)

# Install includes
set(PACKAGES_INCLUDE_DIR "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(GLOB_RECURSE INCLUDE_FILES LIST_DIRECTORIES false RELATIVE "${SOURCE_PATH}" "${SOURCE_PATH}/*.h")
foreach(file_ ${INCLUDE_FILES})
    configure_file("${SOURCE_PATH}/${file_}" "${PACKAGES_INCLUDE_DIR}/${file_}" COPYONLY)
endforeach()

configure_file("${CMAKE_CURRENT_LIST_DIR}/chromium-baseConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/chromium-baseConfig.cmake" @ONLY)

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/third_party/ced/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)
