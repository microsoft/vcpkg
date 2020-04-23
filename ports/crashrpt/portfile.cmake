vcpkg_fail_port_install(ON_TARGET "OSX" "Linux" "UWP")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    set(ARCH_DIR "")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(ARCH_DIR "x64/")
else()
    vcpkg_fail_port_install(MESSAGE "${PORT} only supports x86 and x64 architectures" ALWAYS)
endif()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://git.code.sf.net/p/crashrpt/code
    REF 4616504670be5a425a525376648d912a72ce18f2
    PATCHES
        001-cmake-install.patch
        002-find-minizip-png-zlib.patch
)

# Remove vendored dependencies to ensure they are not picked up by the build
foreach(DEPENDENCY libpng minizip zlib)
    if(EXISTS ${SOURCE_PATH}/thirdparty/${DEPENDENCY})
        file(REMOVE_RECURSE ${SOURCE_PATH}/thirdparty/${DEPENDENCY})
    endif()
endforeach()

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
        -DCRASHRPT_BUILD_DEMOS=OFF
        -DCRASHRPT_BUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
