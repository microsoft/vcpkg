vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-event-stream
    REF "v${VERSION}"
    SHA512 c92bb81e2dd1652a2aef2de391584055c44847736366f6c4afa4033529fdc64fc2ec5ea5604f33cc5fd755359e22dca9db7682f40cf75b187625d6670a68fdab
    HEAD_REF master
    PATCHES fix-cmake-target-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_MODULE_PATH=${CURRENT_INSTALLED_DIR}/share/aws-c-common"
        -DBUILD_TESTING=FALSE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/aws-c-event-stream/cmake)

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug/include"
	"${CURRENT_PACKAGES_DIR}/debug/lib/aws-c-event-stream"
	"${CURRENT_PACKAGES_DIR}/lib/aws-c-event-stream"
	)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE	"${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
