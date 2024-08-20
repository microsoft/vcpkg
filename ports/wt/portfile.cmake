vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emweb/wt
    REF "${VERSION}"
    SHA512 f41efec1e77bd76f6f66ffb4ff38c98cfc590debb194682e3c6eb3f7b4366c30f8e2bbc16f4c33faa45f6f49d28812215538d20f4abc6c4dc3a226ae9b10ac71
    HEAD_REF master
    PATCHES
        0005-XML_file_path.patch
        0006-GraphicsMagick.patch
        fix-compatibility-with-boost-1.85.patch
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

        -DCMAKE_INSTALL_DIR=share
        # see https://redmine.webtoolkit.eu/issues/9646
        -DWTHTTP_CONFIGURATION=
        -DCONFIGURATION=
        
        "-DUSERLIB_PREFIX=${CURRENT_INSTALLED_DIR}"
    MAYBE_UNUSED_VARIABLES
        USE_SYSTEM_SQLITE3

)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/var" "${CURRENT_PACKAGES_DIR}/debug/var")

# RUNDIR is only used for wtfcgi what we don't build. See https://redmine.webtoolkit.eu/issues/9646
file(READ "${CURRENT_PACKAGES_DIR}/include/Wt/WConfig.h" W_CONFIG_H)
string(REGEX REPLACE "([\r\n])#define RUNDIR[^\r\n]+" "\\1// RUNDIR intentionally unset by vcpkg" W_CONFIG_H "${W_CONFIG_H}")
file(WRITE "${CURRENT_PACKAGES_DIR}/include/Wt/WConfig.h" "${W_CONFIG_H}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_copy_pdbs()
