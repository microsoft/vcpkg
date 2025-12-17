vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IfcOpenShell/IfcOpenShell
    REF "ifcopenshell-python-${VERSION}"
    SHA512 ac8f7c8364f7b4fbbf14291d981702272f57dc9f7ab654b105caa8ab7b68e390aaade759e2a18743899f2cc1767c50e5d1208aaeca40f7469e08ec0ad02c5612
    HEAD_REF master
    PATCHES
        dynamic-build-fixes.patch
        opencascade.patch
        cmake-config.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "ifcgeom" BUILD_IFCGEOM
        "opencascade" WITH_OPENCASCADE

        # TODO features:
        "convert" BUILD_CONVERT # Build IfcConvert executable
        "geomserver" BUILD_GEOMSERVER # Build IfcGeomServer executable
        "examples" BUILD_EXAMPLES # Build example applications
        "cgal" WITH_CGAL # Enable geometry interpretation using CGAL
        "collada" COLLADA_SUPPORT # Build IfcConvert with COLLADA support
        "gltf" GLTF_SUPPORT # Build IfcConvert with glTF support
        "ifcmax" BUILD_IFCMAX # Build IfcMax, a 3ds Max plug-in
        "hdf5" HDF5_SUPPORT # Enable HDF5 support
        "proj" WITH_PROJ # Enable output of Earth-Centered Earth-Fixed glTF output using the PROJ library
        "python" BUILD_IFCPYTHON # Build IfcPython
        "qt" BUILD_QTVIEWER # Build IfcOpenShell Qt GUI Viewer
        "usd" USD_SUPPORT # Build IfcConvert with USD support
        "ifcxml" IFCXML_SUPPORT # Build IfcParse with ifcXML support
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DSCHEMA_VERSIONS=2x3;4;4x3_add2" # https://github.com/IfcOpenShell/IfcOpenShell/issues/1029#issuecomment-1882752366
        -DBUILD_DOCUMENTATION=OFF
        -DUSE_MMAP=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME IfcOpenShell CONFIG_PATH share/IfcOpenShell)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LESSER")
