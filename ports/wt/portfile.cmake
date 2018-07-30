include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emweb/wt
    REF 4.0.3
    SHA512 5985f72cbd3065ac696aad4d11711f2d69e066ee17141b56fd7c2616c7f7353586ab8d13db2baa90fa8f3cb116aa7c9044ee3cc42e99e8f5c8704f886ac3b2b6
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001-boost-1.66.patch
        ${CMAKE_CURRENT_LIST_DIR}/0002-link-glew.patch
        ${CMAKE_CURRENT_LIST_DIR}/0003-disable-boost-autolink.patch
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
