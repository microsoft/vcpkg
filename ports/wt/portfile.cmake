include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emweb/wt
    REF 4.0.5
    SHA512 5513b428bfd3e778726c947606677f3e0774b38e640e61cd94906a2e0c75d204a68072b54ddeb3614a7ba08f5668e6eb3a96d9c8df3744b09dc36ad9be12d924
    HEAD_REF master
    PATCHES
        0002-link-glew.patch
        0003-disable-boost-autolink.patch
        0004-link-ssl.patch
		0005-XML_file_path.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SHARED_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
		-DINSTALL_CONFIG_FILE_PATH="${DOWNLOADS}/wt"
        -DSHARED_LIBS=${SHARED_LIBS}
        -DBOOST_DYNAMIC=ON
        -DDISABLE_BOOST_AUTOLINK=ON
        -DBUILD_EXAMPLES=OFF

        -DENABLE_SSL=ON
        -DENABLE_HARU=OFF
        -DENABLE_PANGO=ON
        -DENABLE_SQLITE=ON
        -DENABLE_POSTGRES=ON
        -DENABLE_FIREBIRD=OFF
        -DENABLE_MYSQL=OFF
        -DENABLE_QT4=OFF
        -DENABLE_LIBWTTEST=OFF
        -DENABLE_OPENGL=ON

        -DUSE_SYSTEM_SQLITE3=ON
        -DUSE_SYSTEM_GLEW=ON

        -DCMAKE_INSTALL_DIR=share
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/wt)

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/var)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/var)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/wt RENAME copyright)
vcpkg_copy_pdbs()
