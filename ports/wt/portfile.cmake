vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emweb/wt
    REF 5fdfa9b373d7faf5c6e91725bfb9393e2ab6f081 # 4.2.1
    SHA512 29354e8070252778a9fb888111cbce4a810ad9993fc68996475d9ddc2131ae3ce1dcf35e393ef825db1c889f7e92e353195df6e699f761ff55cc5c19990b16a4
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
vcpkg_fixup_cmake_targets()

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/var)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/var)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
vcpkg_copy_pdbs()
