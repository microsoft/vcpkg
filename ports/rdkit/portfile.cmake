string(REPLACE "." "_" RDKIT_TAG "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdkit/rdkit
    REF "Release_${RDKIT_TAG}"
    SHA512 7f45afde23b4df28aaa3dca8c66feac915deb155056027c2b7984737a96f8508eead1f955192cc9f84651254f3fe83bd96ce1e63fd9bb54f814dac7db109bca3
    HEAD_REF master
    PATCHES
        patches/skip-catch2-when-tests-off.patch
        patches/fix-config-prefix.patch
        patches/use-eigen-config.patch
        patches/respect-static-libs-only.patch
        patches/windows-boost-zlib.patch
)

# Upstream CMake FetchContent / file(DOWNLOAD)s extra sources during configure.
# Vendor them here so the build stays offline after the vcpkg fetch step.
vcpkg_from_github(
    OUT_SOURCE_PATH BETTER_ENUMS_SOURCE
    REPO aantron/better-enums
    REF c35576bed0295689540b39873126129adfa0b4c8
    SHA512 023506e55729c4da13b839926862e485297731372c6ed272120690327eb2ac1c09300023c63ea41f4999340762ce77816d6f95bca4a97ea567c6849f0fbd81aa
    HEAD_REF master
)

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

# Android NDK clang defines INFINITY in float.h; RingDecomposerLib uses it as a
# local unsigned sentinel (UINT_MAX) and fails with "conflicting types for __builtin_inff".
vcpkg_replace_string(
    "${SOURCE_PATH}/External/RingFamilies/RingDecomposerLib/src/RingDecomposerLib/RDLapsp.c"
    "INFINITY"
    "RDL_INFINITY"
)

# Upstream FindEigen3.cmake requests version 2.91.0 (old Eigen world numbering),
# which rejects Eigen 5.x's CMake package. Use Eigen's own config instead.
file(REMOVE "${SOURCE_PATH}/Code/cmake/Modules/FindEigen3.cmake")
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "set(RDKit_ShareDir \"share/RDKit\")" "set(RDKit_ShareDir \"share/rdkit\")")
vcpkg_replace_string("${SOURCE_PATH}/rdkit-config.cmake.in"
    "find_dependency(Boost @Boost_VERSION_STRING@ COMPONENTS \${RDKit_USE_BOOST_COMPONENTS})"
    "find_dependency(Boost @Boost_VERSION_STRING@ CONFIG COMPONENTS \${RDKit_USE_BOOST_COMPONENTS})")

# Upstream FindCairo.cmake links only libcairo and drops pkg-config Requires
# (pixman, fontconfig, Apple frameworks). Replace it with an imported target.
file(WRITE "${SOURCE_PATH}/Code/cmake/Modules/FindCairo.cmake" [[
find_package(PkgConfig REQUIRED)
pkg_check_modules(Cairo REQUIRED IMPORTED_TARGET cairo)
if(NOT TARGET Cairo::Cairo)
    add_library(Cairo::Cairo ALIAS PkgConfig::Cairo)
endif()
set(Cairo_FOUND TRUE)
set(CAIRO_FOUND TRUE)
]])

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cairo RDK_BUILD_CAIRO_SUPPORT
)

if("cairo" IN_LIST FEATURES)
    set(_rdkit_pkgconf "${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf/pkgconf${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    if(NOT EXISTS "${_rdkit_pkgconf}")
        set(_rdkit_pkgconf "${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf/pkg-config${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
    if(EXISTS "${_rdkit_pkgconf}")
        list(APPEND FEATURE_OPTIONS "-DPKG_CONFIG_EXECUTABLE=${_rdkit_pkgconf}")
    endif()
endif()

set(RDKIT_BOOST_STATIC OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(RDKIT_STATIC OFF)
    set(RDKIT_WINDOWS_DLL OFF)
    if(VCPKG_TARGET_IS_WINDOWS)
        set(RDKIT_WINDOWS_DLL ON)
        # MSVC LNK2005: Queries::Query inlines are emitted in GraphMol.dll and
        # again in later DLLs. Keep this on the RDKit link line only.
        set(VCPKG_LINKER_FLAGS "/FORCE:MULTIPLE ${VCPKG_LINKER_FLAGS}")
    endif()
else()
    set(RDKIT_STATIC ON)
    set(RDKIT_WINDOWS_DLL OFF)
    set(RDKIT_BOOST_STATIC ON)
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
        "-DFETCHCONTENT_SOURCE_DIR_BETTER_ENUMS=${BETTER_ENUMS_SOURCE}"
        -DFETCHCONTENT_FULLY_DISCONNECTED=ON
        -DRDK_INSTALL_INTREE=OFF
        -DRDK_INSTALL_DEV_COMPONENT=ON
        -DRDK_INSTALL_STATIC_LIBS=${RDKIT_STATIC}
        -DRDK_BUILD_STATIC_LIBS_ONLY=${RDKIT_STATIC}
        -DRDK_INSTALL_DLLS_MSVC=${RDKIT_WINDOWS_DLL}
        -DBoost_USE_STATIC_LIBS=${RDKIT_BOOST_STATIC}
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
        RDK_INSTALL_DLLS_MSVC
        RDK_OPTIMIZE_POPCNT
        CMAKE_DISABLE_FIND_PACKAGE_Inchi
        CMAKE_DISABLE_FIND_PACKAGE_maeparser
        CMAKE_DISABLE_FIND_PACKAGE_coordgen
        FETCHCONTENT_SOURCE_DIR_BETTER_ENUMS
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME rdkit CONFIG_PATH lib/cmake/rdkit)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS)
    foreach(prefix IN ITEMS "${CURRENT_PACKAGES_DIR}" "${CURRENT_PACKAGES_DIR}/debug")
        file(GLOB dlls "${prefix}/lib/*.dll")
        if(dlls)
            file(MAKE_DIRECTORY "${prefix}/bin")
            foreach(dll IN LISTS dlls)
                get_filename_component(dll_name "${dll}" NAME)
                file(RENAME "${dll}" "${prefix}/bin/${dll_name}")
            endforeach()
        endif()
    endforeach()
    file(GLOB cmake_files "${CURRENT_PACKAGES_DIR}/share/rdkit/*targets*.cmake")
    foreach(f IN LISTS cmake_files)
        file(READ "${f}" contents)
        string(REGEX REPLACE "/lib/([^\"/]+\\.dll)" "/bin/\\1" contents "${contents}")
        file(WRITE "${f}" "${contents}")
    endforeach()
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/rdkit/Docs"
    "${CURRENT_PACKAGES_DIR}/share/rdkit/Contrib"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
