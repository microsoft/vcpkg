vcpkg_internal_get_cmake_vars(OUTPUT_FILE _VCPKG_CMAKE_VARS_FILE)
include("${_VCPKG_CMAKE_VARS_FILE}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO videolan/x265
    REF 07295ba7ab551bb9c1580fdaee3200f1b45711b7 #v3.4
    SHA512 21a4ef8733a9011eec8b336106c835fbe04689e3a1b820acb11205e35d2baba8c786d9d8cf5f395e78277f921857e4eb8622cf2ef3597bce952d374f7fe9ec29
    HEAD_REF master
    PATCHES
        disable-install-pdb.patch
)

set(HAS_10_BIT OFF)
if("bit10" IN_LIST FEATURES)
    set(HAS_10_BIT ON)
endif()

set(HAS_12_BIT OFF)
if("bit12" IN_LIST FEATURES)
    set(HAS_12_BIT ON)
endif()

set(ENABLE_ASSEMBLY OFF)
if (VCPKG_TARGET_IS_WINDOWS AND (NOT HAS_12_BIT AND NOT HAS_10_BIT))
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    set(ENV{PATH} "$ENV{PATH};${NASM_EXE_PATH}")
    set(ENABLE_ASSEMBLY ON)
endif ()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)

set(FEATURE_OPT_DBG "")
set(FEATURE_OPT_REL "")
set(EXTRA_LIB_DBG "")
set(EXTRA_LIB_REL "")

set(ADDITIONAL_NAME "")
if(VCPKG_TARGET_IS_WINDOWS)
    set(ADDITIONAL_NAME "-static")
endif()

set(x265_lib_name "${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}x265${ADDITIONAL_NAME}${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
set(x265_lib_name_main "${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}x265${ADDITIONAL_NAME}-main${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")

## Usage
#  build_x265(
#      BIT <bit>
#      [FEATURE_OPT_VAR <feature_opt_var_name>]
#      [EXTRA_LIB_VAR <extra_lib_var_name>]
#      [FEATURE_OPT_DBG <feature_options_debug...>]
#      [FEATURE_OPT_REL <feature_options_release...>]
#      [EXTRA_LIB_DBG <extra_lib_debug...>]
#      [EXTRA_LIB_REL <extra_lib_release...>]
#  )
macro(build_x265)
    cmake_parse_arguments(build_x265 "" "BIT;FEATURE_OPT_VAR;EXTRA_LIB_VAR" "FEATURE_OPT_DBG;FEATURE_OPT_REL;EXTRA_LIB_DBG;EXTRA_LIB_REL" ${ARGN})

    set(BUILDING_CORE_FEATURE NO)
    if (${build_x265_BIT} EQUAL 8)
        set(BUILDING_CORE_FEATURE YES)
    endif()
    
    set(OPT "")
    set(OPT_REL "")
    set(OPT_DBG "")
    list(APPEND OPT "-DENABLE_LIBNUMA=NO")
    if (${BUILDING_CORE_FEATURE})
        string(REPLACE ";" "\;" EXTRA_LIB_DBG "${build_x265_EXTRA_LIB_DBG}")
        string(REPLACE ";" "\;" EXTRA_LIB_REL "${build_x265_EXTRA_LIB_REL}")
        if (VCPKG_TARGET_IS_LINUX)
            set(EXTRA_LIB_DBG "${EXTRA_LIB_DBG}\;dl")
            set(EXTRA_LIB_REL "${EXTRA_LIB_DBG}\;dl")
        endif()
        list(APPEND OPT_DBG "-DENABLE_CLI=NO")
        if (build_x265_EXTRA_LIB_DBG)
            list(APPEND OPT_DBG "-DEXTRA_LIB=${EXTRA_LIB_DBG}")
        endif()
        if (build_x265_FEATURE_OPT_DBG)
            list(APPEND OPT_DBG "${build_x265_FEATURE_OPT_DBG}")
        endif()
        if (build_x265_EXTRA_LIB_REL)
            list(APPEND OPT_REL "-DEXTRA_LIB=${EXTRA_LIB_REL}")
        endif()
        if (build_x265_FEATURE_OPT_REL)
            list(APPEND OPT_REL "${build_x265_FEATURE_OPT_REL}")
        endif()
        list(APPEND OPT "-DENABLE_ASSEMBLY=${ENABLE_ASSEMBLY}")
        list(APPEND OPT "-DENABLE_SHARED=${ENABLE_SHARED}")
        
    else ()
        list(APPEND OPT "-DEXPORT_C_API=NO")
        list(APPEND OPT "-DENABLE_ASSEMBLY=${ENABLE_ASSEMBLY}")
        list(APPEND OPT "-DENABLE_SHARED=NO")
        list(APPEND OPT "-DENABLE_CLI=NO")
        list(APPEND OPT "-DHIGH_BIT_DEPTH=YES")   

        if (${build_x265_BIT} EQUAL "12")
            list(APPEND OPT "-DMAIN12=ON")
        endif()
    endif()
    
    vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/source
    PREFER_NINJA
    OPTIONS
        ${OPT}
    OPTIONS_RELEASE
        ${OPT_REL}
    OPTIONS_DEBUG
        ${OPT_DBG}
    )
    vcpkg_build_cmake()
    
    set(x265_lib "x265-${build_x265_BIT}")
    
    if (NOT BUILDING_CORE_FEATURE)
        foreach(BUILDTYPE "debug" "release")
            if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)
                if(BUILDTYPE STREQUAL "debug")
                    set(SHORT_BUILDTYPE "dbg")
                else()
                    set(SHORT_BUILDTYPE "rel")
                endif()
                string(TOUPPER ${SHORT_BUILDTYPE} SHORT_BUILDTYPE_VAR)
                set(FEATURE_OPT_BUILDTYPE_VAR ${build_x265_FEATURE_OPT_VAR}_${SHORT_BUILDTYPE_VAR})
                set(EXTRA_LIB_BUILDTYPE_VAR ${build_x265_EXTRA_LIB_VAR}_${SHORT_BUILDTYPE_VAR})

                file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}/${x265_lib_name} 
                    DESTINATION ${CURRENT_BUILDTREES_DIR}/tmp-${TARGET_TRIPLET}-${SHORT_BUILDTYPE}/${x265_lib})
                list(APPEND ${FEATURE_OPT_BUILDTYPE_VAR} "-DLINKED_${build_x265_BIT}BIT=ON")
                file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE})
                list(APPEND ${EXTRA_LIB_BUILDTYPE_VAR} "${CURRENT_BUILDTREES_DIR}/tmp-${TARGET_TRIPLET}-${SHORT_BUILDTYPE}/${x265_lib}/${x265_lib_name}")
            endif()
        endforeach()
    elseif(NOT ENABLE_SHARED)
        foreach(BUILDTYPE "debug" "release")
            if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)
                if(BUILDTYPE STREQUAL "debug")
                    set(SHORT_BUILDTYPE "dbg")
                else()
                    set(SHORT_BUILDTYPE "rel")
                endif()
                string(TOUPPER ${SHORT_BUILDTYPE} SHORT_BUILDTYPE_VAR)
                if (HAS_10_BIT OR HAS_12_BIT)
                    set(EXTRA_LIB_VAR "build_x265_EXTRA_LIB_${SHORT_BUILDTYPE_VAR}")
                    file(RENAME ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}/${x265_lib_name} ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}/${x265_lib_name_main})
                    set(LIB_FILES "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}/${x265_lib_name_main}")
                    list(APPEND LIB_FILES ${${EXTRA_LIB_VAR}})
                    
                    if(VCPKG_TARGET_IS_WINDOWS)
                        execute_process(COMMAND ${VCPKG_DETECTED_CMAKE_AR} /ignore:4006 /ignore:4221 /OUT:${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}/${x265_lib_name} ${LIB_FILES}  RESULT_VARIABLE AR_EXIT_CODE OUTPUT_VARIABLE AR_STDOUT ERROR_VARIABLE AR_STDERR)
                    elseif(VCPKG_TARGET_IS_LINUX)
                        string(REPLACE ";" "\nADDLIB " LIB_FILES "${LIB_FILES}")
                        execute_process(COMMAND "sh" "-c" "${VCPKG_DETECTED_CMAKE_AR} -M <<EOF
CREATE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}/${x265_lib_name}
ADDLIB ${LIB_FILES}
SAVE
END
EOF" RESULT_VARIABLE AR_EXIT_CODE OUTPUT_VARIABLE AR_STDOUT ERROR_VARIABLE AR_STDERR)
                    endif()
                    if(NOT (AR_EXIT_CODE EQUAL 0))
                        message(FATAL_ERROR "ar exit code: ${AR_EXIT_CODE} out: ${AR_STDOUT} err: ${AR_STDRR}")
                    endif()
                endif()
            endif()
        endforeach()
    endif()
endmacro()

if(HAS_10_BIT)
    build_x265(BIT 10 FEATURE_OPT_VAR FEATURE_OPT EXTRA_LIB_VAR EXTRA_LIB)
endif()

if(HAS_12_BIT)
    build_x265(BIT 12 FEATURE_OPT_VAR FEATURE_OPT EXTRA_LIB_VAR EXTRA_LIB)
endif()

build_x265(
    BIT 8 
    FEATURE_OPT_DBG ${FEATURE_OPT_DBG}
    FEATURE_OPT_REL ${FEATURE_OPT_REL}
    EXTRA_LIB_DBG ${EXTRA_LIB_DBG}
    EXTRA_LIB_REL ${EXTRA_LIB_REL}
)

foreach(BUILDTYPE "debug" "release")
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)
        if(BUILDTYPE STREQUAL "debug")
            set(SHORT_BUILDTYPE "dbg")
            set(CONFIG "Debug")
        else()
            set(SHORT_BUILDTYPE "rel")
            set(CONFIG "Release")
        endif()

    message(STATUS "Installing ${TARGET_TRIPLET}-${SHORT_BUILDTYPE}")

        vcpkg_execute_build_process(
            COMMAND ${CMAKE_COMMAND} --install . --config ${CONFIG}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}
            LOGNAME "install-${TARGET_TRIPLET}-${SHORT_BUILDTYPE}"
        )

    endif()
endforeach()

vcpkg_copy_pdbs()

# remove duplicated include files
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
endif()
vcpkg_copy_tools(TOOL_NAMES x265 AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR VCPKG_TARGET_IS_LINUX)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND (NOT VCPKG_TARGET_IS_MINGW))
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/x265.pc" "-lx265" "-lx265-static")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/x265.pc" "-lx265" "-lx265-static")
        endif()
    endif()
endif()

# maybe create vcpkg_regex_replace_string?

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(READ ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/x265.pc _contents)
    string(REGEX REPLACE "-l(std)?c\\+\\+" "" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/x265.pc "${_contents}")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(READ ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/x265.pc _contents)
    string(REGEX REPLACE "-l(std)?c\\+\\+" "" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/x265.pc "${_contents}")
endif()

if(VCPKG_TARGET_IS_MINGW AND ENABLE_SHARED)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libx265.a)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libx265.a)
    endif()
endif()

if(UNIX)
    foreach(FILE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/x265.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/x265.pc")
        if(EXISTS "${FILE}")
            file(READ "${FILE}" _contents)
            string(REPLACE " -lstdc++" "" _contents "${_contents}")
            string(REPLACE " -lc++" "" _contents "${_contents}")
            string(REPLACE " -lgcc_s" "" _contents "${_contents}")
            string(REPLACE " -lgcc" "" _contents "${_contents}")
            string(REPLACE " -lrt" "" _contents "${_contents}")
            file(WRITE "${FILE}" "${_contents}")
        endif()
    endforeach()
    vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES numa)
else()
    vcpkg_fixup_pkgconfig()
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
