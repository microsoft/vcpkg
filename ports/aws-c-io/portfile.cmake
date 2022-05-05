vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-io
    REF 57b00febac48e78f8bf8cff4c82a249e6648842a # v0.10.7
    SHA512 ffcf5ba4ccdff23ca390fc4eb935f88040447589886348234aa1c24b531401521df99a6ac578c1679a3c1a06dfcef6deb833a0b9d53e31d42576a3ad03ade6fc
    HEAD_REF master
    PATCHES fix-cmake-target-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_MODULE_PATH=${CURRENT_INSTALLED_DIR}/share/aws-c-common" # use extra cmake files
        -DBUILD_TESTING=FALSE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/aws-c-io/cmake)

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug/include"
	"${CURRENT_PACKAGES_DIR}/debug/lib/aws-c-io"
	"${CURRENT_PACKAGES_DIR}/lib/aws-c-io"
	)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE	"${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
