vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Multicorewareinc/x265
    REF "${VERSION}"
    SHA512 270d0db180ecebfc5c2f1fe6451be66042fab69273d073428f4af00420fa0f8b792ecdc71ec1a15ee2860e3b6a325c56295143f117e94fa3616f0ccecb2ded75
    HEAD_REF master
    PATCHES
        disable-install-pdb.patch
        version.patch
        linkage.diff
        pkgconfig.diff
        pthread.diff
        compiler-target.diff
        neon.diff
        advapi32.patch # Required since v4.2 as it is now using RegOpenKeyExA, RegQueryValueExA & RegCloseKey
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    vcpkg_find_acquire_program(NASM)
    set(NASM_OPTION "-DNASM_EXECUTABLE=${NASM}")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_OSX)
        # x265 doesn't create sufficient PIC for asm, breaking usage
        # in shared libs, e.g. the libheif gdk pixbuf plugin.
        # Users can override this in custom triplets.
        set(ASSEMBLY_OPTION "-DENABLE_ASSEMBLY=OFF")
    endif()
elseif(VCPKG_TARGET_IS_WINDOWS)
    set(ASSEMBLY_OPTION "-DENABLE_ASSEMBLY=OFF")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)

if("multilib" IN_LIST FEATURES)
    # Build separate 10-bit and 12-bit static libraries (without the exported C
    # API) and combine them with the 8-bit API library so that a single library
    # can switch bit depths at runtime, following the upstream
    # build/linux/multilib.sh recipe. For static linkage the three archives are
    # merged into one; for dynamic linkage the 10/12-bit archives are embedded
    # into the shared library via EXTRA_LIB.
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        set(x265_lib_base "x265-static")
        set(x265_lib_ext ".lib")
    else()
        set(x265_lib_base "libx265")
        set(x265_lib_ext ".a")
    endif()

    set(multilib_stage "${CURRENT_BUILDTREES_DIR}/multilib-stage")
    file(REMOVE_RECURSE "${multilib_stage}")
    file(MAKE_DIRECTORY "${multilib_stage}")

    set(sub_options
        ${NASM_OPTION}
        ${ASSEMBLY_OPTION}
        -DENABLE_SHARED=OFF
        -DENABLE_CLI=OFF
        -DENABLE_PIC=ON
        -DENABLE_LIBNUMA=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_VLD=ON
        "-DVERSION=${VERSION}"
    )

    function(x265_build_bitdepth stage_name)
        vcpkg_cmake_configure(
            SOURCE_PATH "${SOURCE_PATH}/source"
            OPTIONS
                ${sub_options}
                ${ARGN}
            MAYBE_UNUSED_VARIABLES
                ENABLE_LIBNUMA
        )
        vcpkg_cmake_build()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${x265_lib_base}${x265_lib_ext}"
                DESTINATION "${multilib_stage}")
            file(RENAME
                "${multilib_stage}/${x265_lib_base}${x265_lib_ext}"
                "${multilib_stage}/${stage_name}${x265_lib_ext}")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${x265_lib_base}${x265_lib_ext}"
                DESTINATION "${multilib_stage}")
            file(RENAME
                "${multilib_stage}/${x265_lib_base}${x265_lib_ext}"
                "${multilib_stage}/${stage_name}-dbg${x265_lib_ext}")
        endif()
    endfunction()

    function(x265_merge_static out_path)
        cmake_parse_arguments(PARSE_ARGV 0 arg "" "" "INPUTS")
        if(NOT arg_INPUTS)
            message(FATAL_ERROR "x265_merge_static requires at least one INPUTS argument.")
        endif()
        get_filename_component(out_dir "${out_path}" DIRECTORY)
        get_filename_component(out_name "${out_path}" NAME)
        set(work_dir "${out_dir}/.x265-merge")
        file(REMOVE_RECURSE "${work_dir}")
        file(MAKE_DIRECTORY "${work_dir}")

        set(input_names)
        set(input_index 0)
        foreach(input IN LISTS arg_INPUTS)
            math(EXPR input_index "${input_index}+1")
            get_filename_component(input_name "${input}" NAME)
            get_filename_component(input_ext "${input}" EXT)
            file(COPY "${input}" DESTINATION "${work_dir}")
            file(RENAME "${work_dir}/${input_name}" "${work_dir}/in${input_index}${input_ext}")
            list(APPEND input_names "in${input_index}${input_ext}")
        endforeach()

        if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
            if(DEFINED VCPKG_DETECTED_CMAKE_AR AND VCPKG_DETECTED_CMAKE_AR)
                set(archiver "${VCPKG_DETECTED_CMAKE_AR}")
            else()
                find_program(archiver NAMES lib.exe llvm-lib)
            endif()
            if(NOT archiver)
                message(FATAL_ERROR "Unable to find lib.exe or llvm-lib to merge the x265 multilib static libraries.")
            endif()
            get_filename_component(archiver_name "${archiver}" NAME)
            if(archiver_name MATCHES "llvm-ar" OR archiver_name MATCHES "^ar(\\.exe)?$")
                set(x265_merge_mode "mri")
            else()
                set(x265_merge_mode "msvc")
            endif()
        elseif(VCPKG_TARGET_IS_OSX)
            set(x265_merge_mode "libtool")
        else()
            if(DEFINED VCPKG_DETECTED_CMAKE_AR AND VCPKG_DETECTED_CMAKE_AR)
                set(archiver "${VCPKG_DETECTED_CMAKE_AR}")
            else()
                find_program(archiver NAMES ar)
            endif()
            if(NOT archiver)
                message(FATAL_ERROR "Unable to find ar to merge the x265 multilib static libraries.")
            endif()
            set(x265_merge_mode "mri")
        endif()

        if(x265_merge_mode STREQUAL "mri")
            set(script_contents "CREATE ${out_name}\n")
            foreach(input IN LISTS input_names)
                string(APPEND script_contents "ADDLIB ${input}\n")
            endforeach()
            string(APPEND script_contents "SAVE\nEND\n")
            file(WRITE "${work_dir}/merge.script" "${script_contents}")
            execute_process(
                COMMAND "${archiver}" -M
                WORKING_DIRECTORY "${work_dir}"
                INPUT_FILE "${work_dir}/merge.script"
                RESULT_VARIABLE merge_result
            )
            if(NOT merge_result EQUAL 0)
                message(FATAL_ERROR "Failed to merge the x265 multilib static libraries with ${archiver}: ${merge_result}")
            endif()
        elseif(x265_merge_mode STREQUAL "msvc")
            set(merge_command "/NOLOGO" "/OUT:${work_dir}/${out_name}")
            foreach(input IN LISTS input_names)
                list(APPEND merge_command "${work_dir}/${input}")
            endforeach()
            vcpkg_execute_required_process(
                COMMAND "${archiver}" ${merge_command}
                WORKING_DIRECTORY "${work_dir}"
                LOGNAME "merge-x265-multilib-${TARGET_TRIPLET}"
            )
        elseif(x265_merge_mode STREQUAL "libtool")
            set(merge_command libtool -static -o "${work_dir}/${out_name}")
            foreach(input IN LISTS input_names)
                list(APPEND merge_command "${work_dir}/${input}")
            endforeach()
            vcpkg_execute_required_process(
                COMMAND ${merge_command}
                WORKING_DIRECTORY "${work_dir}"
                LOGNAME "merge-x265-multilib-${TARGET_TRIPLET}"
            )
        endif()

        if(EXISTS "${out_path}")
            file(REMOVE "${out_path}")
        endif()
        file(RENAME "${work_dir}/${out_name}" "${out_path}")
        file(REMOVE_RECURSE "${work_dir}")
    endfunction()

    # 12-bit sub-library (namespace x265_12bit, no exported C API)
    x265_build_bitdepth(x265_main12 "-DHIGH_BIT_DEPTH=ON" "-DMAIN12=ON" "-DEXPORT_C_API=OFF")
    # 10-bit sub-library (namespace x265_10bit, no exported C API)
    x265_build_bitdepth(x265_main10 "-DHIGH_BIT_DEPTH=ON" "-DEXPORT_C_API=OFF")

    # Combine the two sub-libraries into a single archive so that EXTRA_LIB can
    # point to one file (semicolon lists do not survive cmake -D parsing here).
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        x265_merge_static("${multilib_stage}/x265_extra${x265_lib_ext}"
            INPUTS
                "${multilib_stage}/x265_main10${x265_lib_ext}"
                "${multilib_stage}/x265_main12${x265_lib_ext}")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        x265_merge_static("${multilib_stage}/x265_extra-dbg${x265_lib_ext}"
            INPUTS
                "${multilib_stage}/x265_main10-dbg${x265_lib_ext}"
                "${multilib_stage}/x265_main12-dbg${x265_lib_ext}")
    endif()

    # 8-bit API library that statically embeds the 10/12-bit libraries
    if("tool" IN_LIST FEATURES)
        set(cli_option "-DENABLE_CLI=ON")
    else()
        set(cli_option "-DENABLE_CLI=OFF")
    endif()
    file(TO_CMAKE_PATH "${multilib_stage}/x265_extra${x265_lib_ext}" extra_lib_rel)
    file(TO_CMAKE_PATH "${multilib_stage}/x265_extra-dbg${x265_lib_ext}" extra_lib_dbg)

    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}/source"
        OPTIONS
            ${NASM_OPTION}
            ${ASSEMBLY_OPTION}
            -DENABLE_SHARED=${ENABLE_SHARED}
            ${cli_option}
            -DENABLE_PIC=ON
            -DENABLE_LIBNUMA=OFF
            "-DVERSION=${VERSION}"
            "-DEXTRA_LIB=${extra_lib_rel}"
            -DLINKED_10BIT=ON
            -DLINKED_12BIT=ON
        OPTIONS_DEBUG
            -DENABLE_CLI=OFF
            "-DEXTRA_LIB=${extra_lib_dbg}"
        MAYBE_UNUSED_VARIABLES
            ENABLE_LIBNUMA
    )
    vcpkg_cmake_build()
    vcpkg_cmake_install()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        # Merge the 10/12-bit code into the installed 8-bit API archives
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            x265_merge_static("${CURRENT_PACKAGES_DIR}/lib/${x265_lib_base}${x265_lib_ext}"
                INPUTS
                    "${CURRENT_PACKAGES_DIR}/lib/${x265_lib_base}${x265_lib_ext}"
                    "${multilib_stage}/x265_extra${x265_lib_ext}")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            x265_merge_static("${CURRENT_PACKAGES_DIR}/debug/lib/${x265_lib_base}${x265_lib_ext}"
                INPUTS
                    "${CURRENT_PACKAGES_DIR}/debug/lib/${x265_lib_base}${x265_lib_ext}"
                    "${multilib_stage}/x265_extra-dbg${x265_lib_ext}")
        endif()
    endif()
else()
    vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
        FEATURES
            tool   ENABLE_CLI
    )

    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}/source"
        OPTIONS
            ${NASM_OPTION}
            ${ASSEMBLY_OPTION}
            ${OPTIONS}
            -DENABLE_SHARED=${ENABLE_SHARED}
            -DENABLE_PIC=ON
            -DENABLE_LIBNUMA=OFF
            "-DVERSION=${VERSION}"
        OPTIONS_DEBUG
            -DENABLE_CLI=OFF
        MAYBE_UNUSED_VARIABLES
            ENABLE_LIBNUMA
    )

    vcpkg_cmake_install()
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES x265 AUTO_CLEAN)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/x265.h" "#ifdef X265_API_IMPORTS" "#if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
