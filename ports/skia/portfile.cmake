vcpkg_fail_port_install(ON_TARGET "WINDOWS" "UWP" "LINUX" "ANDROID" "FREEBSD")

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://skia.googlesource.com/skia.git
    REF 05676f7bc238f667de848dfd37b4aa3c01b69efb
)

vcpkg_from_git(
    OUT_SOURCE_PATH DEPOT_TOOLS_PATH
    URL https://chromium.googlesource.com/chromium/tools/depot_tools.git
    REF 4fad85878aa650f73aa74f3b00a66c9195fd0d57
)

find_program(GN gn PATHS "${SOURCE_PATH}/bin" "${DEPOT_TOOLS_PATH}")
find_program(PYTHON3 python3 PATHS "${DEPOT_TOOLS_PATH}/python-bin")
find_program(NINJA ninja PATHS "${DEPOT_TOOLS_PATH}")

message(STATUS "Syncing git dependencies...")
vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" tools/git-sync-deps
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME sync-deps-${TARGET_TRIPLET}
)

set(OPTIONS "\
skia_use_system_libjpeg_turbo=false \
skia_use_system_libpng=false \
skia_use_system_libwebp=false \
skia_use_system_icu=false")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OPTIONS "${OPTIONS} is_component_build=true")
else()
    set(OPTIONS "${OPTIONS} is_component_build=false")
endif()

if("metal" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} skia_use_metal=true")
endif()

set(OPTIONS_REL "${OPTIONS} is_official_build=true")
set(OPTIONS_DBG "${OPTIONS} is_debug=true")

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
vcpkg_execute_required_process(
    COMMAND "${NINJA}" -C "${BUILD_DIR_DBG}" skia
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME build-${TARGET_TRIPLET}-dbg
)

message(STATUS "Building Skia (release)...")
vcpkg_execute_required_process(
    COMMAND "${NINJA}" -C "${BUILD_DIR_REL}" skia
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME build-${TARGET_TRIPLET}-rel
)

function(file_regex_replace match_regex replace_expr file_)
    file(READ "${file_}" file_data)
    string(REGEX REPLACE "${match_regex}" "${replace_expr}" 
        file_data "${file_data}")
    file(WRITE "${file_}" "${file_data}")
endfunction()

message(STATUS "Installing: ${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(COPY "${SOURCE_PATH}/include" 
    DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/include" 
    "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(GLOB_RECURSE SKIA_INCLUDE_FILES LIST_DIRECTORIES false 
    "${CURRENT_PACKAGES_DIR}/include/${PORT}/*")
foreach(file_ ${SKIA_INCLUDE_FILES})
    file_regex_replace("#include \"include/" "#include \"${PORT}/" "${file_}")
endforeach()

find_library(SKIA_LIBRARY_DBG skia PATHS "${BUILD_DIR_DBG}" NO_DEFAULT_PATH)
file(INSTALL "${SKIA_LIBRARY_DBG}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

find_library(SKIA_LIBRARY_REL skia PATHS "${BUILD_DIR_REL}" NO_DEFAULT_PATH)
file(INSTALL "${SKIA_LIBRARY_REL}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

# get a list of library dependencies for TARGET
function(gn_desc_target_libs SOURCE_PATH BUILD_DIR TARGET OUTPUT)
    execute_process(
        COMMAND ${GN} desc "${BUILD_DIR}" "${TARGET}" libs
        WORKING_DIRECTORY "${SOURCE_PATH}"
        OUTPUT_VARIABLE OUTPUT_
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REGEX REPLACE "\n|(\r\n)" ";" OUTPUT_ ${OUTPUT_})
    set(${OUTPUT} ${OUTPUT_} PARENT_SCOPE)
endfunction()

# skiaConfig.cmake.in input variables
gn_desc_target_libs("${SOURCE_PATH}" "${BUILD_DIR_DBG}" //:skia SKIA_DEP_DBG)
gn_desc_target_libs("${SOURCE_PATH}" "${BUILD_DIR_REL}" //:skia SKIA_DEP_REL)
get_filename_component(SKIA_LIBRARY_NAME_DBG "${SKIA_LIBRARY_DBG}" NAME)
get_filename_component(SKIA_LIBRARY_NAME_REL "${SKIA_LIBRARY_REL}" NAME)

configure_file("${CMAKE_CURRENT_LIST_DIR}/skiaConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/skia/skiaConfig.cmake" @ONLY)

file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)
