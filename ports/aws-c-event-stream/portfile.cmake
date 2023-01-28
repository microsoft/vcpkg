vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-event-stream
    REF 2f9b60c42f90840ec11822acda3d8cdfa97a773d # v0.2.18
    SHA512 e9817d2c0a8a6f9862b73466660123e7f98af992914e4f1f61797697b174e58cba44e1138178e60f11d178e7c2b941fce5895a6cf2d58966df8987276d061216
    HEAD_REF master
    PATCHES fix-cmake-target-path.patch
		fix-cmake-config-file.patch
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
