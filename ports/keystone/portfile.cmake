include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REF 0.9.1
    REPO "keystone-engine/keystone"
    SHA512 3bd9c3793d5862a0a8628b52da381625e62445f661dbd5ed715723e7d9db01ce3f9586e5ca0a5cc71e8ceb6c912050f5c28e3ccd540e72c8abcfd2f0d1bbae17
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KEYSTONE_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" KEYSTONE_BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DKEYSTONE_BUILD_STATIC=${KEYSTONE_BUILD_STATIC}
        -DKEYSTONE_BUILD_SHARED=${KEYSTONE_BUILD_SHARED}

        # Add support for only a subset of architectures
        #-DLLVM_TARGETS_TO_BUILD="AArch64;X86"

    OPTIONS_RELEASE
        -DCMAKE_BUILD_TYPE=Release
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(GLOB EXES ${CURRENT_PACKAGES_DIR}/bin/*.exe ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
if(EXES)
    file(REMOVE ${EXES})
endif()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Move DLLs
file(GLOB DLLS ${CURRENT_PACKAGES_DIR}/lib/*.dll)
file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE ${DLLS})
file(GLOB DLLS ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE ${DLLS})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/keystone 
    RENAME copyright)
