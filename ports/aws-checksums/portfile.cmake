vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-checksums
    REF ad53be196a25bbefa3700a01187fdce573a7d2d0 # v0.1.14
    SHA512 f8a1554d21ff1fc3bcb80d59219da8759056a5c4e01803793b483c3465880b0ab622717cc8a03b4d2a3682116b5b2029c8925cc66f47b38e165855dbdc542398
    HEAD_REF master
    PATCHES fix-cmake-target-path.patch
)

if (VCPKG_CRT_LINKAGE STREQUAL static)
    set(STATIC_CRT_LNK ON)
else()
    set(STATIC_CRT_LNK OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTATIC_CRT=${STATIC_CRT_LNK}
        "-DCMAKE_MODULE_PATH=${CURRENT_INSTALLED_DIR}/share/aws-c-common" # use extra cmake files
        -DBUILD_TESTING=FALSE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/aws-checksums/cmake)

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug/include"
	"${CURRENT_PACKAGES_DIR}/debug/lib/aws-checksums"
	"${CURRENT_PACKAGES_DIR}/lib/aws-checksums"
)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
