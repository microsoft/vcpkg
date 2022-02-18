
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Coin3D/soqt
    REF SoQt-1.6.0
    SHA512 204d49769dda1a9833093ff78bdb788df0c514e800ae0bc35d4ef832ece304c7c26fc7d893ee83db95c34d9457e27e04c74301bcd2029aa3a0f96ec2ecbb3984
    HEAD_REF master
    PATCHES
        disable-cpackd.patch
        disable-test-code.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOANYDATA_SOURCE_PATH
    REPO coin3d/soanydata
    REF 3ff6e9203fbb0cc08a2bdf209212b7ef4d78a1f2
    SHA512 9e176feda43a12ccdf8756f7329517936357499771a7d0a58357d343bdea125c34f8734ff1cd16cda3eeee58090dc1680999849c50132c30940a23d3f81a5c66
    HEAD_REF master
)

if(NOT EXISTS "${SOURCE_PATH}/data")
    file(RENAME "${SOANYDATA_SOURCE_PATH}" "${SOURCE_PATH}/data")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOGUI_SOURCE_PATH
    REPO coin3d/sogui
    REF fb79af47cff89f0f3657501601a7ea5c11968b17
    SHA512 bcf4d2e04c3b6ac87a6425d90c6077ec655732bcc0f99bf181ff2dfce8d356509f52d71b884660fafddc135551ee8fbb139e02b6706d2a01be006193918d232b
    HEAD_REF master
)

if(NOT EXISTS "${SOURCE_PATH}/src/Inventor/Qt/common")
    file(RENAME "${SOGUI_SOURCE_PATH}" "${SOURCE_PATH}/src/Inventor/Qt/common")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SOQT_BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSOQT_BUILD_DOCUMENTATION=OFF
        -DSOQT_BUILD_SHARED_LIBS=${SOQT_BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SoQt-1.6.0)
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
