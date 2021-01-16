vcpkg_check_linkage(ONLY_DYNAMIC_CRT ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libplist
    REF bbba7cabb78aad180a7a982ada5e1f21ff0ba873 # v1.3.6
    SHA512 4cd59ed87c647259d0da99a20a05e01aa880f01f6b5cecd29e4247029a3d29f0f68b4552571eb3fd3c5549b4cb357801ffe43338b8ff34d44d6be5393d2e6b9d
    HEAD_REF msvc-master
    PATCHES dllexport.patch
)

configure_file(${CURRENT_PORT_DIR}/CMakeLists.txt ${SOURCE_PATH}/CMakeLists.txt COPYONLY)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

set(pcfile "libplist-2.0.pc")
set(pcfiletarget "libplist.pc")
set(basepath "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/")
if(EXISTS "${basepath}${pcfile}")
    file(CREATE_LINK "${basepath}${pcfile}" "${basepath}${pcfiletarget}" COPY_ON_ERROR)
endif()
set(basepath "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/")
if(EXISTS "${basepath}${pcfile}")
    file(CREATE_LINK "${basepath}${pcfile}" "${basepath}${pcfiletarget}" COPY_ON_ERROR)
endif()

set(pcfile "libplist++-2.0.pc")
set(pcfiletarget "libplist++.pc")
set(basepath "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/")
if(EXISTS "${basepath}${pcfile}")
    file(CREATE_LINK "${basepath}${pcfile}" "${basepath}${pcfiletarget}" COPY_ON_ERROR)
endif()
set(basepath "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/")
if(EXISTS "${basepath}${pcfile}")
    file(CREATE_LINK "${basepath}${pcfile}" "${basepath}${pcfiletarget}" COPY_ON_ERROR)
endif()
