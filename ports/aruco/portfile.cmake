vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aruco/aruco
    SHA512 19357e057a64c9dc483747eb84f57df13f46ceddd8ef13b9c155bcdf4da6bb9457bbbc01b310abf9e15460537512e664766734909cf8c80fe51e9f2d644fb1f0
    FILENAME "aruco-3.1.12.zip"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/aruco/copyright" COPYONLY)

vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES 
        aruco_batch_processing
        aruco_calibration
        aruco_calibration_fromimages
        aruco_create_markermap
        aruco_dcf
        aruco_dcf_mm
        aruco_markermap_pix2meters
        aruco_print_dictionary
        aruco_print_marker
        aruco_simple
        aruco_simple_markermap
        aruco_test
        aruco_test_markermap
        aruco_tracker
        fractal_tracker
    AUTO_CLEAN
)