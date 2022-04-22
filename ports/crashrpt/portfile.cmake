if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    set(ARCH_DIR "")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(ARCH_DIR "x64/")
else()
    message(FATAL_ERROR "${PORT} only supports x86 and x64 architectures")
endif()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://git.code.sf.net/p/crashrpt/code
    REF 4616504670be5a425a525376648d912a72ce18f2
    PATCHES
        001-add-install-target-and-find-deps.patch
)

# Remove vendored dependencies to ensure they are not picked up by the build
# Vendored minizip is still used since it contains modifications needed for CrashRpt
foreach(DEPENDENCY dbghelp jpeg libogg libpng libtheora tinyxml wtl zlib)
    if(EXISTS ${SOURCE_PATH}/thirdparty/${DEPENDENCY})
        file(REMOVE_RECURSE ${SOURCE_PATH}/thirdparty/${DEPENDENCY})
    endif()
endforeach()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CRASHRPT_BUILD_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" CRASHRPT_LINK_CRT_AS_DLL)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        probe CRASHRPT_BUILD_PROBE
        tests CRASHRPT_BUILD_TESTS
        demos CRASHRPT_BUILD_DEMOS
)

# PREFER_NINJA is not used below since CrashSender fails to build with errors like this one:
# C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Tools\MSVC\14.23.28105\ATLMFC\include\atlconv.h(788): error C2440: 'return': cannot convert from 'LPCTSTR' to 'LPCOLESTR'
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # PREFER_NINJA
    OPTIONS
        -DCRASHRPT_BUILD_SHARED_LIBS=${CRASHRPT_BUILD_SHARED_LIBS}
        -DCRASHRPT_LINK_CRT_AS_DLL=${CRASHRPT_LINK_CRT_AS_DLL}
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
