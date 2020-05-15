
# fail early for unsupported triplets
vcpkg_fail_port_install(
    MESSAGE "mmLoader supports only x86/x64-windows-static triplets"
    ON_TARGET "UWP" "LINUX" "OSX" "ANDROID" "FREEBSD"
    ON_ARCH "arm" "arm64"
    ON_CRT_LINKAGE "dynamic"
    ON_LIBRARY_LINKAGE "dynamic"
)

# source
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tishion/mmLoader
    REF 0.0.9
    SHA512 5af5cec0e3911f1e034acd8804f13bcee06fc634214a550177378cdebdbadbecfbeacb8775600fd25ea50940e02638f92cc8f2702bf7d33fffaef6146ef866c8
    HEAD_REF release-vcpkg
)

# feature
set(MMLOADER_FEATURE_SHELLCODE OFF)
if ("shellcode" IN_LIST FEATURES)
    set(MMLOADER_FEATURE_SHELLCODE ON)
endif()

# config
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_SHELLCODE_GEN=${MMLOADER_FEATURE_SHELLCODE}
)

# pre-clean
file(REMOVE_RECURSE ${SOURCE_PATH}/output)

# build
vcpkg_build_cmake(DISABLE_PARALLEL)

# collect header files
file(GLOB mmLoader_HEADERS 
    ${SOURCE_PATH}/output/mmloader/include/*.h
)
file(INSTALL ${mmLoader_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/mmLoader)

# collect binary files
file(GLOB_RECURSE mmLoader_libs 
    ${SOURCE_PATH}/output/mmloader/*/lib/Release/*.lib
    ${SOURCE_PATH}/output/mmloader/*/lib/Release/*.pdb
)
if(mmLoader_libs)
    file(INSTALL ${mmLoader_libs} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
endif()

file(GLOB_RECURSE mmLoader_debug_libs 
    ${SOURCE_PATH}/output/mmloader/*/lib/Debug/*.lib
    ${SOURCE_PATH}/output/mmloader/*/lib/Debug/*.pdb
)
if(mmLoader_debug_libs)
    file(INSTALL ${mmLoader_debug_libs} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

# collect tools
if (MMLOADER_FEATURE_SHELLCODE)
    file(GLOB_RECURSE mmLoader_tools 
        ${SOURCE_PATH}/output/mmloader/*/bin/Release/*.exe
        ${SOURCE_PATH}/output/mmloader/*/bin/Release/*.pdb
    )
    file(INSTALL ${mmLoader_tools} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)    

    file(GLOB_RECURSE mmLoader_debug_tools 
        ${SOURCE_PATH}/output/mmloader/*/bin/Debug/*.exe
        ${SOURCE_PATH}/output/mmloader/*/bin/Debug/*.pdb
    )
    file(INSTALL ${mmLoader_debug_tools} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)
endif()

# collect license files
file(INSTALL ${SOURCE_PATH}/License DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
