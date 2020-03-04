vcpkg_fail_port_install(
    ON_ARCH "x86" "arm" "arm64"
    ON_TARGET "UWP" "LINUX" "ANDROID" "FREEBSD")

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://skia.googlesource.com/skia.git
    REF 05676f7bc238f667de848dfd37b4aa3c01b69efb
)

find_program(GIT NAMES git git.cmd)
set(ENV{GIT_EXECUTABLE} "${GIT}")

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON2_DIR}")

vcpkg_find_acquire_program(NINJA)

message(STATUS "Syncing git dependencies...")
vcpkg_execute_required_process(
    COMMAND "${PYTHON2}" tools/git-sync-deps
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME sync-deps-${TARGET_TRIPLET}
)

find_program(GN gn PATHS "${SOURCE_PATH}/bin" "${DEPOT_TOOLS_PATH}")

set(OPTIONS "\
skia_use_system_libjpeg_turbo=false \
skia_use_system_libpng=false \
skia_use_system_libwebp=false \
skia_use_system_icu=false \
skia_use_system_expat=false \
skia_use_system_zlib=false")

# used for passing feature-specific definitions to the config file
set(SKIA_PUBLIC_DEFINITIONS "")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OPTIONS "${OPTIONS} is_component_build=true")
else()
    set(OPTIONS "${OPTIONS} is_component_build=false")
endif()

if("metal" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} skia_use_metal=true")
    list(APPEND SKIA_PUBLIC_DEFINITIONS SK_METAL)
endif()

set(OPTIONS_REL "${OPTIONS} is_official_build=true")
set(OPTIONS_DBG "${OPTIONS} is_debug=true")

function(find_msvc_path PATH)
    vcpkg_get_program_files_32_bit(PROGRAM_FILES)
    file(TO_CMAKE_PATH "${PROGRAM_FILES}" PROGRAM_FILES)
    set(VSWHERE "${PROGRAM_FILES}/Microsoft Visual Studio/Installer/vswhere.exe")
    execute_process(
        COMMAND "${VSWHERE}" -prerelease -legacy -products * -sort -utf8 -property installationPath
        WORKING_DIRECTORY "${SOURCE_PATH}"
        OUTPUT_VARIABLE OUTPUT_
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REGEX REPLACE "\n|(\r\n)" ";" OUTPUT_ "${OUTPUT_}")
    list(GET OUTPUT_ 0 OUTPUT_)
    
    set(${PATH} "${OUTPUT_}" PARENT_SCOPE)
endfunction()

if(CMAKE_HOST_WIN32)
    # Load toolchains
    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
    endif()
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")

    # turn a space delimited string into a gn list:
    # "a b c" -> ["a","b","c"]
    function(to_gn_list OUTPUT_ INPUT_)
        string(STRIP "${INPUT_}" TEMP)
        string(REPLACE "  " " " TEMP "${TEMP}")
        string(REPLACE " " "\",\"" TEMP "${TEMP}")
        set(${OUTPUT_} "[\"${TEMP}\"]" PARENT_SCOPE)
    endfunction()

    to_gn_list(SKIA_C_FLAGS_DBG "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG}")
    to_gn_list(SKIA_C_FLAGS_REL "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}")

    to_gn_list(SKIA_CXX_FLAGS_DBG "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
    to_gn_list(SKIA_CXX_FLAGS_REL "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")

    set(OPTIONS_DBG "${OPTIONS_DBG} extra_cflags_c=${SKIA_C_FLAGS_DBG} \
        extra_cflags_cc=${SKIA_CXX_FLAGS_DBG}")

    set(OPTIONS_REL "${OPTIONS_REL} extra_cflags_c=${SKIA_C_FLAGS_REL} \
        extra_cflags_cc=${SKIA_CXX_FLAGS_REL}")

    find_msvc_path(WIN_VC)
    set(WIN_VC "${WIN_VC}\\VC")
    set(OPTIONS_DBG "${OPTIONS_DBG} win_vc=\"${WIN_VC}\"")
    set(OPTIONS_REL "${OPTIONS_REL} win_vc=\"${WIN_VC}\"")

endif()

set(BUILD_DIR_REL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
set(BUILD_DIR_DBG "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

message(STATUS "Generating build (debug)...")
vcpkg_execute_required_process(
    COMMAND "${GN}" gen "${BUILD_DIR_DBG}" --args=${OPTIONS_DBG}
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME generate-${TARGET_TRIPLET}-dbg
)

message(STATUS "Generating build (release)...")
vcpkg_execute_required_process(
    COMMAND "${GN}" gen "${BUILD_DIR_REL}" --args=${OPTIONS_REL}
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME generate-${TARGET_TRIPLET}-rel
)

message(STATUS "Building Skia (debug)...")
vcpkg_execute_build_process(
    COMMAND "${NINJA}" -C "${BUILD_DIR_DBG}" skia
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME build-${TARGET_TRIPLET}-dbg
)

message(STATUS "Building Skia (release)...")
vcpkg_execute_build_process(
    COMMAND "${NINJA}" -C "${BUILD_DIR_REL}" skia
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME build-${TARGET_TRIPLET}-rel
)

message(STATUS "Installing: ${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(COPY "${SOURCE_PATH}/include" 
    DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/include" 
    "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(GLOB_RECURSE SKIA_INCLUDE_FILES LIST_DIRECTORIES false 
    "${CURRENT_PACKAGES_DIR}/include/${PORT}/*")
foreach(file_ ${SKIA_INCLUDE_FILES})
    vcpkg_replace_string("${file_}" "#include \"include/" "#include \"${PORT}/")
endforeach()

if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB SKIA_LIBRARY_DBG LIST_DIRECTORIES false
        "${BUILD_DIR_DBG}/skia*.lib")
    list(GET SKIA_LIBRARY_DBG 0 SKIA_LIBRARY_DBG)
    file(INSTALL "${SKIA_LIBRARY_DBG}" 
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

    file(GLOB SKIA_LIBRARY_REL LIST_DIRECTORIES false
        "${BUILD_DIR_REL}/skia*.lib")
    list(GET SKIA_LIBRARY_REL 0 SKIA_LIBRARY_REL)
    file(INSTALL "${SKIA_LIBRARY_REL}" 
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        get_filename_component(SKIA_LIBRARY_IMPLIB_DBG 
            "${SKIA_LIBRARY_DBG}" NAME)
        get_filename_component(SKIA_LIBRARY_IMPLIB_REL 
            "${SKIA_LIBRARY_REL}" NAME)

        file(GLOB SKIA_LIBRARY_DBG LIST_DIRECTORIES false
            "${BUILD_DIR_DBG}/skia*.dll")
        list(GET SKIA_LIBRARY_DBG 0 SKIA_LIBRARY_DBG)
        file(INSTALL "${SKIA_LIBRARY_DBG}" 
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        get_filename_component(SKIA_LIBRARY_NAME_DBG "${SKIA_LIBRARY_DBG}" NAME)

        file(GLOB SKIA_LIBRARY_DBG LIST_DIRECTORIES false
            "${BUILD_DIR_DBG}/skia*.pdb")
        list(GET SKIA_LIBRARY_DBG 0 SKIA_LIBRARY_DBG)
        file(INSTALL "${SKIA_LIBRARY_DBG}" 
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

        file(GLOB SKIA_LIBRARY_REL LIST_DIRECTORIES false
            "${BUILD_DIR_REL}/skia*.dll")
        list(GET SKIA_LIBRARY_REL 0 SKIA_LIBRARY_REL)
        file(INSTALL "${SKIA_LIBRARY_REL}" 
            DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        get_filename_component(SKIA_LIBRARY_NAME_REL "${SKIA_LIBRARY_REL}" NAME)
    else()
        get_filename_component(SKIA_LIBRARY_NAME_DBG "${SKIA_LIBRARY_DBG}" NAME)
        get_filename_component(SKIA_LIBRARY_NAME_REL "${SKIA_LIBRARY_REL}" NAME)
    endif()
else()
    find_library(SKIA_LIBRARY_DBG skia PATHS "${BUILD_DIR_DBG}" NO_DEFAULT_PATH)
    file(INSTALL "${SKIA_LIBRARY_DBG}" 
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

    find_library(SKIA_LIBRARY_REL skia PATHS "${BUILD_DIR_REL}" NO_DEFAULT_PATH)
    file(INSTALL "${SKIA_LIBRARY_REL}" 
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

    get_filename_component(SKIA_LIBRARY_NAME_DBG "${SKIA_LIBRARY_DBG}" NAME)
    get_filename_component(SKIA_LIBRARY_NAME_REL "${SKIA_LIBRARY_REL}" NAME)
endif()

# get a list of library dependencies for TARGET
function(gn_desc_target_libs SOURCE_PATH BUILD_DIR TARGET OUTPUT)
    execute_process(
        COMMAND ${GN} desc "${BUILD_DIR}" "${TARGET}" libs
        WORKING_DIRECTORY "${SOURCE_PATH}"
        OUTPUT_VARIABLE OUTPUT_
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REGEX REPLACE "\n|(\r\n)" ";" OUTPUT_ "${OUTPUT_}")
    set(${OUTPUT} ${OUTPUT_} PARENT_SCOPE)
endfunction()

# skiaConfig.cmake.in input variables
gn_desc_target_libs("${SOURCE_PATH}" "${BUILD_DIR_DBG}" //:skia SKIA_DEP_DBG)
gn_desc_target_libs("${SOURCE_PATH}" "${BUILD_DIR_REL}" //:skia SKIA_DEP_REL)

configure_file("${CMAKE_CURRENT_LIST_DIR}/skiaConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/skia/skiaConfig.cmake" @ONLY)

vcpkg_copy_pdbs()
file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)
