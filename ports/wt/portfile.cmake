vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emweb/wt
    REF d3ee790da1826529e3d025d919f5c3608d029562 # 4.5.0
    SHA512 2fe66269bb59db81d3611f2857ac3ba0ae7448a54d216bd7aa72701f1e6e291a738421f460f4614198785bbd084ab1e19e84a3f67cbc15556015e2f259941f11
    HEAD_REF master
    PATCHES
        0002-link-glew.patch
        0005-XML_file_path.patch
        0006-GraphicsMagick.patch
        0007-boost_1_77_0.patch
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
    SOURCE_PATH ${SOURCE_PATH}
    GENERATOR Ninja
    OPTIONS
        -DINSTALL_CONFIG_FILE_PATH="${DOWNLOADS}/wt"
        -DSHARED_LIBS=${SHARED_LIBS}
        -DBOOST_DYNAMIC=${SHARED_LIBS}
        -DDISABLE_BOOST_AUTOLINK=ON
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF

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
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/var)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/var)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
vcpkg_copy_pdbs()
