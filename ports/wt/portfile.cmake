vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emweb/wt
    REF d0e9f2e8096a1acb4558130a851812dd424d8f3e # 4.7.1
    SHA512 ddda642e464a0c93017161404911cd8261e105971162171cd6aa0e4334e22b5f284a753e8b81a4f43c9269b14389abd28c61e2cdfe706b414808e82fc4bc1680
    HEAD_REF master
    PATCHES
        0002-link-glew.patch
        0005-XML_file_path.patch
        0006-GraphicsMagick.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SHARED_LIBS)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS
    FEATURE_OPTIONS
    FEATURES
        dbo        ENABLE_LIBWTDBO
        postgresql ENABLE_POSTGRES
        sqlite3    ENABLE_SQLITE
        sqlserver  ENABLE_MSSQLSERVER
        openssl    ENABLE_SSL
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(WT_PLATFORM_SPECIFIC_OPTIONS
        -DWT_WRASTERIMAGE_IMPLEMENTATION=Direct2D
        -DCONNECTOR_ISAPI=ON
        -DENABLE_PANGO=OFF)
else()
    set(WT_PLATFORM_SPECIFIC_OPTIONS
        -DCONNECTOR_FCGI=OFF
        -DENABLE_PANGO=ON
        -DHARFBUZZ_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/harfbuzz)

    if ("graphicsmagick" IN_LIST FEATURES)
        list(APPEND WT_PLATFORM_SPECIFIC_OPTIONS
            -DWT_WRASTERIMAGE_IMPLEMENTATION=GraphicsMagick)
    else()
        list(APPEND WT_PLATFORM_SPECIFIC_OPTIONS
            -DWT_WRASTERIMAGE_IMPLEMENTATION=none)
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    GENERATOR Ninja
    OPTIONS
        -DINSTALL_CONFIG_FILE_PATH="${DOWNLOADS}/wt"
        -DSHARED_LIBS=${SHARED_LIBS}
        -DBOOST_DYNAMIC=${SHARED_LIBS}
        -DDISABLE_BOOST_AUTOLINK=ON
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF

        -DWTHTTP_CONFIGURATION=
        -DCONFIGURATION=

        -DCONNECTOR_HTTP=ON
        -DENABLE_HARU=ON
        -DHARU_DYNAMIC=${SHARED_LIBS}
        -DENABLE_MYSQL=OFF
        -DENABLE_FIREBIRD=OFF
        -DENABLE_QT4=OFF
        -DENABLE_QT5=OFF
        -DENABLE_LIBWTTEST=ON
        -DENABLE_OPENGL=ON

        ${FEATURE_OPTIONS}
        ${WT_PLATFORM_SPECIFIC_OPTIONS}

        -DUSE_SYSTEM_SQLITE3=ON
        -DUSE_SYSTEM_GLEW=ON

        -DCMAKE_INSTALL_DIR=share
        # see https://redmine.webtoolkit.eu/issues/9646
        -DWTHTTP_CONFIGURATION=
        -DCONFIGURATION=

)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/var" "${CURRENT_PACKAGES_DIR}/debug/var")

# RUNDIR is only used for wtfcgi what we don't build. See https://redmine.webtoolkit.eu/issues/9646
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/Wt/WConfig.h" "#define RUNDIR \"${CURRENT_PACKAGES_DIR}/var/run/wt\"" "")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
vcpkg_copy_pdbs()
