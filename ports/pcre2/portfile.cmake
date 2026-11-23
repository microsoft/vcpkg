set(head_extract_options "")

if(VCPKG_USE_HEAD_VERSION)
    set(repository "https://github.com/PCRE2Project/pcre2.git")
    set(snapshot_name "PCRE2Project-pcre2-main")
    set(submodule_options "")
    if("jit" IN_LIST FEATURES)
        string(APPEND snapshot_name "-jit")
        # Check out the SLJIT commit recorded by PCRE2.
        set(submodule_options --recurse-submodules=deps/sljit --shallow-submodules)
    endif()

    set(version_file "${DOWNLOADS}/${snapshot_name}.git-version")
    if(_VCPKG_NO_DOWNLOADS)
        if(NOT EXISTS "${version_file}")
            message(FATAL_ERROR "Downloads are disabled, but '${version_file}' does not exist.")
        endif()
        file(STRINGS "${version_file}" VCPKG_HEAD_VERSION LIMIT_COUNT 1)
    else()
        vcpkg_find_acquire_program(GIT)
        set(checkout "${CURRENT_BUILDTREES_DIR}/src/pcre2-checkout-${TARGET_TRIPLET}")
        file(REMOVE_RECURSE "${checkout}")
        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND "${GIT}" -c core.autocrlf=false -c core.longpaths=true
                clone --depth 1 --branch main ${submodule_options} "${repository}" "${checkout}"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
            LOGNAME git-clone-${TARGET_TRIPLET}
        )
        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND "${GIT}" rev-parse HEAD
            WORKING_DIRECTORY "${checkout}"
            LOGNAME git-rev-parse-${TARGET_TRIPLET}
            OUTPUT_VARIABLE VCPKG_HEAD_VERSION
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    endif()

    set(archive "${DOWNLOADS}/${snapshot_name}-${VCPKG_HEAD_VERSION}.tar.gz")
    if(NOT _VCPKG_NO_DOWNLOADS)
        string(RANDOM LENGTH 16 temporary_suffix)
        file(MAKE_DIRECTORY "${DOWNLOADS}")
        if(NOT EXISTS "${archive}")
            # Archive the populated checkout so the usual extraction and patching flow can be used.
            file(REMOVE_RECURSE "${checkout}/.git")
            file(REMOVE "${checkout}/deps/sljit/.git")
            set(temporary_archive "${archive}.${temporary_suffix}.part")
            vcpkg_execute_required_process(
                ALLOW_IN_DOWNLOAD_MODE
                COMMAND "${CMAKE_COMMAND}" -E tar czf "${temporary_archive}" --format=gnutar .
                WORKING_DIRECTORY "${checkout}"
                LOGNAME archive-head-${TARGET_TRIPLET}
            )
            file(RENAME "${temporary_archive}" "${archive}" NO_REPLACE RESULT rename_result)
            if(NOT rename_result STREQUAL "0" AND NOT rename_result STREQUAL "NO_REPLACE")
                message(FATAL_ERROR "Could not store PCRE2 HEAD snapshot: ${rename_result}")
            endif()
            file(REMOVE "${temporary_archive}")
        endif()
        file(REMOVE_RECURSE "${checkout}")

        # Publish the commit pointer after its snapshot is available for --no-downloads.
        file(WRITE "${version_file}.${temporary_suffix}.part" "${VCPKG_HEAD_VERSION}\n")
        file(RENAME "${version_file}.${temporary_suffix}.part" "${version_file}")
    elseif(NOT EXISTS "${archive}")
        message(FATAL_ERROR "Downloads are disabled, but '${archive}' does not exist.")
    endif()

    set(head_extract_options BASE_DIRECTORY "src/head" NO_REMOVE_ONE_LEVEL SKIP_PATCH_CHECK)
    z_vcpkg_add_spdx_resource(
        NAME "PCRE2Project/pcre2"
        DOWNLOAD_LOCATION "git+${repository}@${VCPKG_HEAD_VERSION}"
    )
else()
    # The official release tarball includes the matching SLJIT sources.
    vcpkg_download_distfile(archive
        URLS "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${VERSION}/pcre2-${VERSION}.tar.gz"
        FILENAME "pcre2-${VERSION}.tar.gz"
        SHA512 6cfd9f824837078bea959ea89c1494950987892ec9b8546691b1aa94fde37c60429c4711c55f9a629c8a6a86bb6ebae738b3a0ebf6e42c70ab008ec6c394aca0
    )
endif()

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${archive}"
    ${head_extract_options}
    PATCHES
        pcre2-10.35_fix-uwp.patch
        no-static-suffix.patch
        fix-msvc-pdb-install.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" INSTALL_MSVC_PDB)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        jit   PCRE2_SUPPORT_JIT
)

if(VCPKG_TARGET_IS_ANDROID)
    list(APPEND FEATURE_OPTIONS -DHAVE_VSCRIPT_GNU=FALSE)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DPCRE2_BUILD_PCRE2_8=ON
        -DPCRE2_BUILD_PCRE2_16=ON
        -DPCRE2_BUILD_PCRE2_32=ON
        -DPCRE2_SUPPORT_UNICODE=ON
        -DPCRE2_BUILD_TESTS=OFF
        -DPCRE2_BUILD_PCRE2GREP=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_BZip2=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ZLIB=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Readline=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Editline=ON
        -DINSTALL_MSVC_PDB=${INSTALL_MSVC_PDB}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

if(BUILD_STATIC_LIBS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/pcre2.h" "defined(PCRE2_STATIC)" "1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/pcre2.h" "defined(PCRE2_STATIC)" "0")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/pcre2")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/pcre2-config" "${CURRENT_PACKAGES_DIR}/tools/pcre2/pcre2-config")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/pcre2/pcre2-config" "${CURRENT_PACKAGES_DIR}" [[$(cd "$(dirname "$0")/../.."; pwd -P)]])
if(NOT VCPKG_BUILD_TYPE)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/pcre2/debug")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/pcre2-config" "${CURRENT_PACKAGES_DIR}/tools/pcre2/debug/pcre2-config")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/pcre2/debug/pcre2-config" "${CURRENT_PACKAGES_DIR}/debug" [[$(cd "$(dirname "$0")/../../../debug"; pwd -P)]])
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/pcre2/debug/pcre2-config" [[${prefix}/include]] [[${prefix}/../include]])
endif()
vcpkg_clean_executables_in_bin(FILE_NAMES none)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
set(copyright_files "${SOURCE_PATH}/LICENCE.md")
if(PCRE2_SUPPORT_JIT)
    list(APPEND copyright_files "${SOURCE_PATH}/deps/sljit/LICENSE")
endif()
vcpkg_install_copyright(FILE_LIST ${copyright_files})
