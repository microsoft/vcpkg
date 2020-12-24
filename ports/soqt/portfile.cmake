vcpkg_fail_port_install(ON_TARGET "UWP" ON_ARCH "arm" "arm64")

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

if(VCPKG_HEAD_VERSION)
    vcpkg_download_distfile(
        SOANYDATA_ARCHIVE
        URLS "https://github.com/coin3d/soanydata/archive/master.tar.gz"
        FILENAME "Coin3D-soanydata-master.tar.gz"
        SKIP_SHA512
    )
else()
    vcpkg_download_distfile(
        SOANYDATA_ARCHIVE
        URLS "https://github.com/coin3d/soanydata/archive/3ff6e9203fbb0cc08a2bdf209212b7ef4d78a1f2.tar.gz"
        FILENAME "Coin3D-soanydata-3ff6e9203fbb0cc08a2bdf209212b7ef4d78a1f2.tar.gz"
        SHA512 9e176feda43a12ccdf8756f7329517936357499771a7d0a58357d343bdea125c34f8734ff1cd16cda3eeee58090dc1680999849c50132c30940a23d3f81a5c66
    )
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOANYDATA_SOURCE_PATH
    ARCHIVE ${SOANYDATA_ARCHIVE}
)

if(NOT EXISTS ${SOURCE_PATH}/data)
    file(RENAME ${SOANYDATA_SOURCE_PATH} ${SOURCE_PATH}/data)
endif()

if(VCPKG_HEAD_VERSION)
    vcpkg_download_distfile(
        SOGUI_ARCHIVE
        URLS "https://github.com/coin3d/sogui/archive/master.tar.gz"
        FILENAME "Coin3D-sogui-master.tar.gz"
        SKIP_SHA512
    )
else()
    vcpkg_download_distfile(
        SOGUI_ARCHIVE
        URLS "https://github.com/coin3d/sogui/archive/fb79af47cff89f0f3657501601a7ea5c11968b17.tar.gz"
        FILENAME "Coin3D-sogui-fb79af47cff89f0f3657501601a7ea5c11968b17.tar.gz"
        SHA512 bcf4d2e04c3b6ac87a6425d90c6077ec655732bcc0f99bf181ff2dfce8d356509f52d71b884660fafddc135551ee8fbb139e02b6706d2a01be006193918d232b
    )
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOGUI_SOURCE_PATH
    ARCHIVE ${SOGUI_ARCHIVE}
)

if(NOT EXISTS ${SOURCE_PATH}/src/Inventor/Qt/common)
    file(RENAME ${SOGUI_SOURCE_PATH} ${SOURCE_PATH}/src/Inventor/Qt/common)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(SOQT_BUILD_SHARED_LIBS OFF)
else()
    set(SOQT_BUILD_SHARED_LIBS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSOQT_BUILD_DOCUMENTATION=OFF
        -DSOQT_BUILD_SHARED_LIBS=${SOQT_BUILD_SHARED_LIBS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/SoQt-1.6.0)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
