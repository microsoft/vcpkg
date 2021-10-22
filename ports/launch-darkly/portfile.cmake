vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO launchdarkly/c-client-sdk
    REF 74449310619f8793ab8c2ed09a0793f0a75fdcda # 2.3.1
    SHA512 8d956bc3c4a6e2bf6886a05d7db2b61fd932f0e4b8ab18c77b64500159c7c95edd02c7038b948211f0751718d54886bc73addc3496553a02c82feec96e6da262
    HEAD_REF master
    PATCHES
        add-cpp-target.patch
        x64linux-fixes.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
        "-DBUILD_BENCHMARKS=OFF"
)

vcpkg_cmake_install()

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/ldclientapi.dll ${CURRENT_PACKAGES_DIR}/bin/ldclientapi.dll)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/ldclientapicpp.dll ${CURRENT_PACKAGES_DIR}/bin/ldclientapicpp.dll)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/ldclientapi.dll ${CURRENT_PACKAGES_DIR}/debug/bin/ldclientapi.dll)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/ldclientapicpp.dll ${CURRENT_PACKAGES_DIR}/debug/bin/ldclientapicpp.dll)
    endif()
endif()

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug/include"
	"${CURRENT_PACKAGES_DIR}/debug/lib/launch-darkly"
	"${CURRENT_PACKAGES_DIR}/lib/launch-darkly"
	)
    
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
