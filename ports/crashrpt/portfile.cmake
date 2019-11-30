include(vcpkg_common_functions)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fail_port_install(MESSAGE "${PORT} only supports Windows platform" ALWAYS)
endif()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://git.code.sf.net/p/crashrpt/code
    REF 4616504670be5a425a525376648d912a72ce18f2
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CRASHRPT_BUILD_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" CRASHRPT_LINK_CRT_AS_DLL)

# PREFER_NINJA is not used below since CrashSender fails to build with errors like this one:
# C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Tools\MSVC\14.23.28105\ATLMFC\include\atlconv.h(788): error C2440: 'return': cannot convert from 'LPCTSTR' to 'LPCOLESTR'
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # PREFER_NINJA
    OPTIONS
        -DCRASHRPT_BUILD_SHARED_LIBS=${CRASHRPT_BUILD_SHARED_LIBS}
        -DCRASHRPT_LINK_CRT_AS_DLL=${CRASHRPT_LINK_CRT_AS_DLL}
)

# CrashRpt does not have an install target, so build the two targets that are needed and copy the output
vcpkg_build_cmake(TARGET CrashSender)
vcpkg_build_cmake(TARGET CrashRpt)

file(INSTALL ${SOURCE_PATH}/include/CrashRpt.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

set(DEBUG_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
set(RELEASE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(INSTALL ${DEBUG_DIR}/lib/CrashRpt1403d.exp DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(INSTALL ${DEBUG_DIR}/lib/CrashRpt1403d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(INSTALL ${DEBUG_DIR}/bin/CrashRpt1403d.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    
    file(INSTALL ${RELEASE_DIR}/lib/CrashRpt1403.exp DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL ${RELEASE_DIR}/lib/CrashRpt1403.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL ${RELEASE_DIR}/bin/CrashRpt1403.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
else()
    file(INSTALL ${DEBUG_DIR}/lib/CrashRptLIBd.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    
    file(INSTALL ${RELEASE_DIR}/lib/CrashRptLIB.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
endif()

file(INSTALL ${DEBUG_DIR}/bin/CrashSender1403d.exe DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT})
file(INSTALL ${RELEASE_DIR}/bin/CrashSender1403.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(GLOB LANG_FILES "${SOURCE_PATH}/lang_files/crashrpt_lang_*.ini")
file(INSTALL ${LANG_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(INSTALL ${SOURCE_PATH}/thirdparty/dbghelp/bin/dbghelp.dll DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/debug/tools/${PORT})
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
