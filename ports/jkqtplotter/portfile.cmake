string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" JKQtPlotter_BUILD_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static"  JKQtPlotter_BUILD_STATIC_LIBS)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jkriege2/JKQtPlotter
    REF a9bfcab4b96cd7bdeac30902f5d7a31b765c522b 
    SHA512 04b20eb66c833eac5dcd6a50c966217380b0f3a6e70092e36b80197b94d1ea2858b2b9f09aec5e02df2effab5b9b17059436589d727060bba3601ec1342278a9
    HEAD_REF master
    PATCHES
        fix-cmake.patch
        fix-cmake2.patch
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "add_subdirectory(doc)" "")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "examples"       JKQtPlotter_BUILD_EXAMPLES
        "tools"          JKQtPlotter_BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DJKQtPlotter_BUILD_SHARED_LIBS=${JKQtPlotter_BUILD_SHARED_LIBS}
        -DJKQtPlotter_BUILD_STATIC_LIBS=${JKQtPlotter_BUILD_STATIC_LIBS}
        ${FEATURE_OPTIONS}
        -DCMAKE_IGNORE_PATH=${CURRENT_INSTALLED_DIR}/share/cmake/Qt5
        -DCIMG_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenCV:BOOL=ON # only used for some examples
        -DOpenCV_FOUND:BOOL=FALSE # wrong find_package call with QUITE instead of QUIET
    MAYBE_UNUSED_VARIABLES
        OpenCV_FOUND
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

vcpkg_copy_pdbs()
set(tools "")
if("tools" IN_LIST FEATURES)
  list(APPEND tools
      jkqtmathtext_render
      jkqtplotter_doc_imagegenerator
  )
endif()
if("examples" IN_LIST FEATURES)
  list(APPEND tools
      jkqtplot_test
      jkqtptest_advplotstyling
      jkqtptest_barchart
      jkqtptest_boxplot
      jkqtptest_contourplot
      jkqtptest_datastore
      jkqtptest_datastore_groupedstat
      jkqtptest_datastore_iterators
      jkqtptest_datastore_regression
      jkqtptest_datastore_statistics
      jkqtptest_datastore_statistics_2d
      jkqtptest_dateaxes
      jkqtptest_distributionplot
      jkqtptest_errorbarstyles
      jkqtptest_evalcurve
      jkqtptest_filledgraphs
      jkqtptest_functionplot
      jkqtptest_geometric
      jkqtptest_geo_arrows
      jkqtptest_geo_simple
      jkqtptest_imageplot
      jkqtptest_imageplot_cimg
      jkqtptest_imageplot_modifier
      jkqtptest_imageplot_nodatastore
      jkqtptest_imageplot_userpal
      jkqtptest_impulsesplot
      jkqtptest_jkqtfastplotter_test
      jkqtptest_jkqtmathtext_simpletest
      jkqtptest_jkqtmathtext_test
      jkqtptest_logaxes
      jkqtptest_mandelbrot
      jkqtptest_parametriccurve
      jkqtptest_paramscatterplot
      jkqtptest_paramscatterplot_image
      jkqtptest_parsedfunctionplot
      jkqtptest_rgbimageplot
      jkqtptest_rgbimageplot_cimg
      jkqtptest_rgbimageplot_qt
      jkqtptest_simpletest
      jkqtptest_speed
      jkqtptest_stackedbars
      jkqtptest_stepplots
      jkqtptest_styledboxplot
      jkqtptest_styling
      jkqtptest_symbols_and_errors
      jkqtptest_symbols_and_styles
      jkqtptest_ui
      jkqtptest_user_interaction
      jkqtptest_violinplot
      jkqtptest_wiggleplots
      jkqtptest_barchart_customdrawfunctor
      jkqtptest_barchart_errorbars
      jkqtptest_barchart_functorfill
      jkqtptest_barchart_twocolor
      jkqtptest_filledgraphs_errors
      jkqtptest_geo_coordinateaxis0
      jkqtptest_multiplot
      jkqtptest_paramscatterplot_customsymbol
      jkqtptest_scatter
      jkqtptest_scatter_customsymbol
      jkqtptest_second_axis
  )
endif()



if(tools)
  vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/doc" "${CURRENT_PACKAGES_DIR}/debug/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST
  "${SOURCE_PATH}/LICENSE" 
  "${SOURCE_PATH}/lib/jkqtmathtext/resources/firaMath/LICENSE"
  "${SOURCE_PATH}/lib/jkqtmathtext/resources/xits/OFL.txt"
)
