include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emweb/wt
    REF 4.0.4
    SHA512 7f9fee9b1c145adb610bf9b0860867a2f09699a1c914418938955c5648b3207db361ec48b3afe9e6faa6cc0b5874bedd44481fdd8adb8fc558cfc3dc17369ee7
    HEAD_REF master
    PATCHES
        0001-boost-1.66.patch
        0002-link-glew.patch
        0003-disable-boost-autolink.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SHARED_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
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
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/wt)

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/wt RENAME copyright)
vcpkg_copy_pdbs()
