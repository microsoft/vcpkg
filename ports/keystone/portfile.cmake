vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO keystone-engine/keystone
    REF dc7932ef2b2c4a793836caec6ecab485005139d6 # 0.9.2
    SHA512 ebcdb1cca6dfdf76e0ad2a42a667044806e5c083c07357908298c6ef23d15960f887efa05c1cb3dee90ebdcd5af819bcf8af0fa1aa068aa9a0c6703dee29514e
    HEAD_REF master
    PATCHES
        0001-fix-gcc15.patch
        0002-fix-cmake4.patch
)

vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(PKGCONFIG)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" KEYSTONE_BUILD_STATIC_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKEYSTONE_BUILD_STATIC_RUNTIME=${KEYSTONE_BUILD_STATIC_RUNTIME}
        "-DPYTHON_EXECUTABLE=${PYTHON3}"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"

        # Add support for only a subset of architectures
        #-DLLVM_TARGETS_TO_BUILD="AArch64;X86"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    #For windows, do not build kstool if building DLL https://github.com/keystone-engine/keystone/blob/master/CMakeLists.txt#L74
    vcpkg_copy_tools(TOOL_NAMES kstool AUTO_CLEAN)
else()
    # Move DLLs
    file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/lib/*.dll")
    file(COPY ${DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE ${DLLS})
    file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
    file(COPY ${DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE ${DLLS})
endif()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(
    COMMENT [[
Keystone is distributed under dual Version 2 of the GNU General Public License (GPLv2) and commercial license.
For commercial usage in production environments, contact the authors of Keystone to buy a royalty-free license keystone.engine@gmail.com
]]
    FILE_LIST "${SOURCE_PATH}/COPYING"
)
