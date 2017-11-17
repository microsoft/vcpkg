set(BUILD_SHARED_VALUE ON)
set(BUILD_STATIC_VALUE OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
	set(BUILD_SHARED_VALUE OFF)
	set(BUILD_STATIC_VALUE ON)
endif()
set(CRT_STATIC_LIBS_VALUE OFF)
if(VCPKG_CRT_LINKAGE STREQUAL "static")
	set(CRT_STATIC_LIBS_VALUE ON)
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/TinyEXIF
    REF 1.0.0
    SHA512 530b3e165bc51fa5a1bb29ea1f8cb5d7100a995347622d50375fdb5fab36139e9474d97ae2e3d54ac2886c2da1fe7138ed15710277410b6a6504ce05537fff28
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_VALUE}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_VALUE}
        -DLINK_CRT_STATIC_LIBS=${CRT_STATIC_LIBS_VALUE}
        -DBUILD_DEMO=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/tinyexif")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyexif)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tinyexif/README.md)
