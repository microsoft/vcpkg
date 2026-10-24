vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PCRE2Project/pcre2
    REF "pcre2-${VERSION}"
    SHA512 8257285809a9a4afb441869936740ae5ff04cc4bd95f86c8e4b9fd41f3b6a194e88d0aaa1c2cfc01b8845984993736fa5e77201c82021842acc87451d8f62f8b
    HEAD_REF main
    PATCHES
        pcre2-10.35_fix-uwp.patch
        no-static-suffix.patch
        fix-msvc-pdb-install.patch
)

if("jit" IN_LIST FEATURES)
    # GitHub source snapshots omit gitlinks; .gitmodules only records paths and URLs.
    if(VCPKG_USE_HEAD_VERSION)
        set(pcre2_ref "${VCPKG_HEAD_VERSION}")
        set(sljit_gitlink_hash SKIP_SHA512)
    else()
        set(pcre2_ref "pcre2-${VERSION}")
        set(sljit_gitlink_hash SHA512 719fa1d8d8e1e749ce6f7370db32818268f84b1376ed9367fd5290ab440d8bea7a6a25a68e55045a45da68b0ce7a55daa0d7acd2f1b11774319b50268c02441c)
    endif()

    # The key here is that our portfile is hardcoding SHA validation hashes, but not hardcoding the sljit commit
    # to fetch. The 'pcre2-${VERSION}' tag chooses the sljit commit that ought to be fetched.
    # This ensures that a vcpkg maintainer only has to update the SHA hashes until everything passes, when bumping
    # to a new PCRE2 tag. There should be no risk of accidentally specifying mismatched pcre2 and sljit commits.
    vcpkg_download_distfile(sljit_gitlink
        URLS "https://api.github.com/repos/PCRE2Project/pcre2/contents/deps/sljit?ref=${pcre2_ref}"
        FILENAME "pcre2-${pcre2_ref}-sljit-gitlink.json"
        ${sljit_gitlink_hash}
    )
    file(READ "${sljit_gitlink}" sljit_gitlink_contents)
    string(JSON sljit_ref GET "${sljit_gitlink_contents}" sha)
    string(JSON sljit_url GET "${sljit_gitlink_contents}" submodule_git_url)
    string(LENGTH "${sljit_ref}" sljit_ref_length)
    if(NOT sljit_ref MATCHES "^[0-9a-f]+$" OR NOT sljit_ref_length EQUAL 40
        OR NOT sljit_url STREQUAL "https://github.com/zherczeg/sljit.git")
        message(FATAL_ERROR "Unexpected deps/sljit gitlink in PCRE2 ${pcre2_ref}: ${sljit_url} at ${sljit_ref}")
    endif()

    if(VCPKG_USE_HEAD_VERSION)
        # Fetch PCRE2's resolved gitlink, not an independently moving SLJIT HEAD.
        vcpkg_download_distfile(sljit_archive
            URLS "https://github.com/zherczeg/sljit/archive/${sljit_ref}.tar.gz"
            FILENAME "zherczeg-sljit-${sljit_ref}.tar.gz"
            SKIP_SHA512
        )
        vcpkg_extract_source_archive(SLJIT_SOURCE_PATH ARCHIVE "${sljit_archive}")
    else()
        vcpkg_from_github(
            OUT_SOURCE_PATH SLJIT_SOURCE_PATH
            REPO zherczeg/sljit
            REF "${sljit_ref}"
            SHA512 e5cc01f941877558f19859aedc9079c155f752a92e6d94fc5fb716e483b8fcb3a8495a5974bbb545d6d9a947ca97ebb36bfe278c4dc083afeb48b8ccab36895b
        )
    endif()

    file(REMOVE_RECURSE "${SOURCE_PATH}/deps/sljit")
    file(MAKE_DIRECTORY "${SOURCE_PATH}/deps")
    file(RENAME "${SLJIT_SOURCE_PATH}" "${SOURCE_PATH}/deps/sljit")
endif()

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
