include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emweb/wt
    REF 3.3.7
    SHA512 f179b42eedcfd2e61f26ef92c6aad40c55c76c9a688269c4d5bd55dd48381073d6269d9c2ab305f15ef455616d48183a3fc0ba08c740a8e18318a2ad2fb13826
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/add-disable-boost-autolink-option.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(SHARED_LIBS ON)
else()
    set(SHARED_LIBS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
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
)
vcpkg_install_cmake()

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/wt RENAME copyright)
vcpkg_copy_pdbs()
