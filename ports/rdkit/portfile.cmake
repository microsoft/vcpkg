string(REPLACE "." "_" RDKIT_TAG "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdkit/rdkit
    REF "Release_${RDKIT_TAG}"
    SHA512 7f45afde23b4df28aaa3dca8c66feac915deb155056027c2b7984737a96f8508eead1f955192cc9f84651254f3fe83bd96ce1e63fd9bb54f814dac7db109bca3
    HEAD_REF master
    PATCHES
        skip-catch2-when-tests-off.patch
        use-external-better-enums.patch
        fix-config-prefix.patch
        use-eigen-config.patch
        respect-static-libs-only.patch
        windows-boost-zlib.patch
        find-cairo-pkgconfig.patch
        moldraw2d-cairo-link.patch
        fix-install-layout.patch
)

# Upstream downloads these sources during configure. maeparser and coordgenlibs
# do not yet have vcpkg ports; RDKit consumes their source trees through its own
# build. RingDecomposerLib uses an RDKit-specific fork tag, and pubchem-align3d
# has no standalone package configuration. Keep them pinned and install their
# notices while the build remains offline.
vcpkg_from_github(
    OUT_SOURCE_PATH MAEPARSER_SOURCE
    REPO schrodinger/maeparser
    REF "v1.3.3"
    SHA512 00747f5ad20bd48e460bf6d19cfaa69baa704f3599088d1c6df4c60fe5d3ed205a45fc6a559e07a7fb23019a75540aaa5b6cf86f119dcb90ba4d5200fcec92d6
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH COORDGEN_SOURCE
    REPO schrodinger/coordgenlibs
    REF "v3.0.2"
    SHA512 6d331af39dbaec0d2cccff8f727b5cba19ab49b860581eb57f15382bd4e5834ecfccb137fe28943a359f3f43fa09880fd927ffa5d076207a859b145298f8d20f
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH URF_SOURCE
    REPO rareylab/RingDecomposerLib
    REF "v1.1.3_rdkit"
    SHA512 e82b97838a36d9f9557a4b7631de34830572add83d6793a01eec46ff9fe9139481db4262442b3f21c22d822efb5110386ceafb496c2bab2f31ddc26d43525215
    HEAD_REF master
    PATCHES
        ringdecomposerlib-infinity.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH PUBCHEM_SOURCE
    REPO ncbi/pubchem-align3d
    REF daefab3dd0c90ca56da9d3d5e375fe4d651e6be3
    SHA512 b2ceb03e7f4e6ded55310592c29b934da5631df4703b576dd7ad99075c0b626b838b33202f195d3c5f70980da42a2137198b8fdc3750ba2af7afb53a8c123f07
    HEAD_REF master
)

file(COPY "${MAEPARSER_SOURCE}/" DESTINATION "${SOURCE_PATH}/External/CoordGen/maeparser")
file(COPY "${COORDGEN_SOURCE}/" DESTINATION "${SOURCE_PATH}/External/CoordGen/coordgen")
file(COPY "${URF_SOURCE}/" DESTINATION "${SOURCE_PATH}/External/RingFamilies/RingDecomposerLib")
file(COPY "${PUBCHEM_SOURCE}/" DESTINATION "${SOURCE_PATH}/External/pubchem_shape/pubchem-align3d")

# Upstream FindEigen3.cmake requests version 2.91.0 (old Eigen world numbering),
# which rejects Eigen 5.x's CMake package. Use Eigen's own config instead.
file(REMOVE "${SOURCE_PATH}/Code/cmake/Modules/FindEigen3.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cairo RDK_BUILD_CAIRO_SUPPORT
)

if("cairo" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
    set(ENV{PKG_CONFIG} "${PKGCONFIG}")
endif()

# Upstream leaves RDK_INSTALL_DLLS_MSVC OFF: Query templates cannot be
# consistently exported from MSVC DLLs (LNK2005 if the export is empty,
# LNK2019 if they are owned by GraphMol). Match that and install static
# libraries on MSVC even for dynamic CRT triplets.
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

set(RDKIT_STATIC OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(RDKIT_STATIC ON)
endif()

set(RDKIT_POPCNT ON)
if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" AND NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(RDKIT_POPCNT OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFETCHCONTENT_FULLY_DISCONNECTED=ON
        -DRDK_INSTALL_INTREE=OFF
        -DRDK_INSTALL_DEV_COMPONENT=ON
        -DRDK_INSTALL_STATIC_LIBS=${RDKIT_STATIC}
        -DRDK_BUILD_STATIC_LIBS_ONLY=${RDKIT_STATIC}
        -DRDK_INSTALL_DLLS_MSVC=OFF
        -DRDK_BUILD_PYTHON_WRAPPERS=OFF
        -DRDK_BUILD_SWIG_WRAPPERS=OFF
        -DRDK_BUILD_PGSQL=OFF
        -DRDK_BUILD_CPP_TESTS=OFF
        -DRDK_BUILD_CONTRIB=OFF
        -DRDK_BUILD_MINIMAL_LIB=OFF
        -DRDK_BUILD_CFFI_LIB=OFF
        -DRDK_BUILD_INCHI_SUPPORT=OFF
        -DRDK_BUILD_AVALON_SUPPORT=OFF
        -DRDK_BUILD_YAEHMOP_SUPPORT=OFF
        -DRDK_BUILD_FREESASA_SUPPORT=OFF
        -DRDK_BUILD_XYZ2MOL_SUPPORT=OFF
        -DRDK_BUILD_STRUCTCHECKER_SUPPORT=OFF
        -DRDK_BUILD_CHEMDRAW_SUPPORT=OFF
        -DRDK_BUILD_COORDGEN_SUPPORT=ON
        -DRDK_BUILD_MAEPARSER_SUPPORT=ON
        -DRDK_BUILD_DESCRIPTORS3D=ON
        -DRDK_BUILD_PUBCHEMSHAPE_SUPPORT=ON
        -DRDK_BUILD_FREETYPE_SUPPORT=ON
        -DRDK_INSTALL_COMIC_FONTS=OFF
        -DRDK_USE_URF=ON
        -DRDK_USE_BOOST_SERIALIZATION=ON
        -DRDK_USE_BOOST_IOSTREAMS=ON
        -DRDK_USE_BOOST_STACKTRACE=OFF
        -DRDK_OPTIMIZE_POPCNT=${RDKIT_POPCNT}
        -DCMAKE_DISABLE_FIND_PACKAGE_Inchi=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_maeparser=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_coordgen=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_Eigen3=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_Boost=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_Freetype=ON
    MAYBE_UNUSED_VARIABLES
        RDK_INSTALL_DLLS_MSVC # only consumed on MSVC
        RDK_OPTIMIZE_POPCNT # only consumed on x86/x64
        CMAKE_DISABLE_FIND_PACKAGE_Inchi # InChI support is off
        CMAKE_DISABLE_FIND_PACKAGE_maeparser # bundled maeparser, not a find_package
        CMAKE_DISABLE_FIND_PACKAGE_coordgen # bundled coordgen, not a find_package
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rdkit)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/license.txt"
    "${MAEPARSER_SOURCE}/LICENSE.txt"
    "${COORDGEN_SOURCE}/LICENSE"
    "${URF_SOURCE}/LICENSE"
    "${PUBCHEM_SOURCE}/LICENSE"
    "${SOURCE_PATH}/Data/Fonts/roboto_regular_license.txt"
    "${SOURCE_PATH}/Data/Fonts/telex_font_license.txt"
)
