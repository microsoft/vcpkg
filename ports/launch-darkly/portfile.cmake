vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO launchdarkly/c-client-sdk
    REF 74449310619f8793ab8c2ed09a0793f0a75fdcda # 2.3.1
    SHA512 8d956bc3c4a6e2bf6886a05d7db2b61fd932f0e4b8ab18c77b64500159c7c95edd02c7038b948211f0751718d54886bc73addc3496553a02c82feec96e6da262
    HEAD_REF master
    PATCHES
        add-cpp-target.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug/include"
	"${CURRENT_PACKAGES_DIR}/debug/lib/launch-darkly"
	"${CURRENT_PACKAGES_DIR}/lib/launch-darkly"
	)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
