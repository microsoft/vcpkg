if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(link_hdf5_SHARED 0)
else()
    set(link_hdf5_SHARED 1)
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO h5py/h5py
    REF 81ba118ee66b97a94678e8f5675c4114649dfda4
    SHA512 c789abdc563f8d2535f0a2ef5e233eb862281559a9cdc3ec560dd69b4d403b6f923f5390390da54851e1bfef1be8de7f80999c25a7f3ac4962ee0620179c6420
    HEAD_REF master
    PATCHES
		0001-disable-H5PLget_plugin-api.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/lzf)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/lzf
    PREFER_NINJA
    OPTIONS
        -Dlink_hdf5_SHARED=${link_hdf5_SHARED}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/lzf/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
