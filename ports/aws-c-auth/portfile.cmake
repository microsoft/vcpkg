vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-auth
    REF bad1066f0a93f3a7df86c94cc03076fa6b901bd2 # v0.6.22
    SHA512 fc996fbca2ea6410318780b3f33c58cc0cd4790456828fa87c428046365266500ad7ad0d58f0448f27a854c7a8078a261ecc93d89324df3d239f0f96791db361
    HEAD_REF master
    PATCHES fix-cmake-target-path.patch
		fix-cmake-config-file.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_MODULE_PATH=${CURRENT_INSTALLED_DIR}/share/aws-c-common" # use extra cmake files
        -DBUILD_TESTING=FALSE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/aws-c-auth/cmake)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE 
        "${CURRENT_PACKAGES_DIR}/bin" 
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug/include"
	"${CURRENT_PACKAGES_DIR}/debug/lib/aws-c-auth"
	"${CURRENT_PACKAGES_DIR}/lib/aws-c-auth"
	)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
