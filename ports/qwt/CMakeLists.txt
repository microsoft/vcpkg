cmake_minimum_required(VERSION 3.19)

project(qwt LANGUAGES CXX)

option(BUILD_DLL "Must be enabled when building a Windows DLL so that symbols are correctly exported." OFF)
option(WITH_PLOT "Enables all classes, that are needed to use the QwtPlot widget." ON)
option(WITH_OPENGL "If you want to use a OpenGL plot canvas." ON)
option(WITH_SVG "If you want to display svg images on the plot canvas, or export a plot to a SVG document." ON)
option(WITH_POLAR "Enables all classes, that are needed to use the QwtPolar classes. It can't be enabled without also enabling QwtPlot." ON)
option(WITH_WIDGETS "Enables all classes, that are needed to use the all other widgets (sliders, dials, ...), beside QwtPlot." ON)

find_package(Qt6 REQUIRED QUIET COMPONENTS Widgets Svg PrintSupport Concurrent OpenGL OpenGLWidgets)

add_library(qwt)

set(QWT_HEADERS
    src/qwt.h
    src/qwt_abstract_scale_draw.h
    src/qwt_bezier.h
    src/qwt_clipper.h
    src/qwt_color_map.h
    src/qwt_column_symbol.h
    src/qwt_date.h
    src/qwt_date_scale_draw.h
    src/qwt_date_scale_engine.h
    src/qwt_dyngrid_layout.h
    src/qwt_global.h
    src/qwt_graphic.h
    src/qwt_interval.h
    src/qwt_interval_symbol.h
    src/qwt_math.h
    src/qwt_magnifier.h
    src/qwt_null_paintdevice.h
    src/qwt_painter.h
    src/qwt_painter_command.h
    src/qwt_panner.h
    src/qwt_picker.h
    src/qwt_picker_machine.h
    src/qwt_pixel_matrix.h
    src/qwt_point_3d.h
    src/qwt_point_polar.h
    src/qwt_round_scale_draw.h
    src/qwt_scale_div.h
    src/qwt_scale_draw.h
    src/qwt_scale_engine.h
    src/qwt_scale_map.h
    src/qwt_spline.h
    src/qwt_spline_basis.h
    src/qwt_spline_parametrization.h
    src/qwt_spline_local.h
    src/qwt_spline_cubic.h
    src/qwt_spline_pleasing.h
    src/qwt_spline_polynomial.h
    src/qwt_symbol.h
    src/qwt_system_clock.h
    src/qwt_text_engine.h
    src/qwt_text_label.h
    src/qwt_text.h
    src/qwt_transform.h
    src/qwt_widget_overlay.h
)
set(QWT_SOURCES
    src/qwt.cpp
    src/qwt_abstract_scale_draw.cpp
    src/qwt_bezier.cpp
    src/qwt_clipper.cpp
    src/qwt_color_map.cpp
    src/qwt_column_symbol.cpp
    src/qwt_date.cpp
    src/qwt_date_scale_draw.cpp
    src/qwt_date_scale_engine.cpp
    src/qwt_dyngrid_layout.cpp
    src/qwt_event_pattern.cpp
    src/qwt_graphic.cpp
    src/qwt_interval.cpp
    src/qwt_interval_symbol.cpp
    src/qwt_math.cpp
    src/qwt_magnifier.cpp
    src/qwt_null_paintdevice.cpp
    src/qwt_painter.cpp
    src/qwt_painter_command.cpp
    src/qwt_panner.cpp
    src/qwt_picker.cpp
    src/qwt_picker_machine.cpp
    src/qwt_pixel_matrix.cpp
    src/qwt_point_3d.cpp
    src/qwt_point_polar.cpp
    src/qwt_round_scale_draw.cpp
    src/qwt_scale_div.cpp
    src/qwt_scale_draw.cpp
    src/qwt_scale_map.cpp
    src/qwt_scale_engine.cpp
    src/qwt_spline.cpp
    src/qwt_spline_basis.cpp
    src/qwt_spline_parametrization.cpp
    src/qwt_spline_local.cpp
    src/qwt_spline_cubic.cpp
    src/qwt_spline_pleasing.cpp
    src/qwt_spline_polynomial.cpp
    src/qwt_symbol.cpp
    src/qwt_system_clock.cpp
    src/qwt_text_engine.cpp
    src/qwt_text_label.cpp
    src/qwt_text.cpp
    src/qwt_transform.cpp
    src/qwt_widget_overlay.cpp
)

if(WITH_PLOT)
    list(APPEND QWT_HEADERS
        src/qwt_axis.h
        src/qwt_axis_id.h
        src/qwt_curve_fitter.h
        src/qwt_spline_curve_fitter.h
        src/qwt_weeding_curve_fitter.h
        src/qwt_event_pattern.h
        src/qwt_abstract_legend.h
        src/qwt_legend.h
        src/qwt_legend_data.h
        src/qwt_legend_label.h
        src/qwt_plot.h
        src/qwt_plot_renderer.h
        src/qwt_plot_curve.h
        src/qwt_plot_dict.h
        src/qwt_plot_directpainter.h
        src/qwt_plot_graphicitem.h
        src/qwt_plot_grid.h
        src/qwt_plot_histogram.h
        src/qwt_plot_item.h
        src/qwt_plot_abstract_barchart.h
        src/qwt_plot_barchart.h
        src/qwt_plot_multi_barchart.h
        src/qwt_plot_intervalcurve.h
        src/qwt_plot_tradingcurve.h
        src/qwt_plot_layout.h
        src/qwt_plot_marker.h
        src/qwt_plot_zoneitem.h
        src/qwt_plot_textlabel.h
        src/qwt_plot_rasteritem.h
        src/qwt_plot_spectrogram.h
        src/qwt_plot_spectrocurve.h
        src/qwt_plot_scaleitem.h
        src/qwt_plot_legenditem.h
        src/qwt_plot_seriesitem.h
        src/qwt_plot_shapeitem.h
        src/qwt_plot_vectorfield.h
        src/qwt_plot_abstract_canvas.h
        src/qwt_plot_canvas.h
        src/qwt_plot_panner.h
        src/qwt_plot_picker.h
        src/qwt_plot_zoomer.h
        src/qwt_plot_magnifier.h
        src/qwt_plot_rescaler.h
        src/qwt_point_mapper.h
        src/qwt_raster_data.h
        src/qwt_matrix_raster_data.h
        src/qwt_vectorfield_symbol.h
        src/qwt_sampling_thread.h
        src/qwt_samples.h
        src/qwt_series_data.h
        src/qwt_series_store.h
        src/qwt_point_data.h
        src/qwt_scale_widget.h
    )
    list(APPEND QWT_SOURCES
        src/qwt_curve_fitter.cpp
        src/qwt_spline_curve_fitter.cpp
        src/qwt_weeding_curve_fitter.cpp
        src/qwt_abstract_legend.cpp
        src/qwt_legend.cpp
        src/qwt_legend_data.cpp
        src/qwt_legend_label.cpp
        src/qwt_plot.cpp
        src/qwt_plot_renderer.cpp
        src/qwt_plot_axis.cpp
        src/qwt_plot_curve.cpp
        src/qwt_plot_dict.cpp
        src/qwt_plot_directpainter.cpp
        src/qwt_plot_graphicitem.cpp
        src/qwt_plot_grid.cpp
        src/qwt_plot_histogram.cpp
        src/qwt_plot_item.cpp
        src/qwt_plot_abstract_barchart.cpp
        src/qwt_plot_barchart.cpp
        src/qwt_plot_multi_barchart.cpp
        src/qwt_plot_intervalcurve.cpp
        src/qwt_plot_zoneitem.cpp
        src/qwt_plot_tradingcurve.cpp
        src/qwt_plot_spectrogram.cpp
        src/qwt_plot_spectrocurve.cpp
        src/qwt_plot_scaleitem.cpp
        src/qwt_plot_legenditem.cpp
        src/qwt_plot_seriesitem.cpp
        src/qwt_plot_shapeitem.cpp
        src/qwt_plot_vectorfield.cpp
        src/qwt_plot_marker.cpp
        src/qwt_plot_textlabel.cpp
        src/qwt_plot_layout.cpp
        src/qwt_plot_abstract_canvas.cpp
        src/qwt_plot_canvas.cpp
        src/qwt_plot_panner.cpp
        src/qwt_plot_rasteritem.cpp
        src/qwt_plot_picker.cpp
        src/qwt_plot_zoomer.cpp
        src/qwt_plot_magnifier.cpp
        src/qwt_plot_rescaler.cpp
        src/qwt_point_mapper.cpp
        src/qwt_raster_data.cpp
        src/qwt_matrix_raster_data.cpp
        src/qwt_vectorfield_symbol.cpp
        src/qwt_sampling_thread.cpp
        src/qwt_series_data.cpp
        src/qwt_point_data.cpp
        src/qwt_scale_widget.cpp
    )
endif()

if(WITH_OPENGL)
    list(APPEND QWT_HEADERS src/qwt_plot_opengl_canvas.h)
    list(APPEND QWT_SOURCES src/qwt_plot_opengl_canvas.cpp)
endif()

if (WITH_SVG)
    list(APPEND QWT_HEADERS src/qwt_plot_svgitem.h)
    list(APPEND QWT_SOURCES src/qwt_plot_svgitem.cpp)
endif()

if (WITH_POLAR)
    list(APPEND QWT_HEADERS
        src/qwt_polar.h
        src/qwt_polar_canvas.h
        src/qwt_polar_curve.h
        src/qwt_polar_fitter.h
        src/qwt_polar_grid.h
        src/qwt_polar_itemdict.h
        src/qwt_polar_item.h
        src/qwt_polar_layout.h
        src/qwt_polar_magnifier.h
        src/qwt_polar_marker.h
        src/qwt_polar_panner.h
        src/qwt_polar_picker.h
        src/qwt_polar_plot.h
        src/qwt_polar_renderer.h
        src/qwt_polar_spectrogram.h
    )
    list(APPEND QWT_SOURCES
        src/qwt_polar_canvas.cpp
        src/qwt_polar_curve.cpp
        src/qwt_polar_fitter.cpp
        src/qwt_polar_grid.cpp
        src/qwt_polar_item.cpp
        src/qwt_polar_itemdict.cpp
        src/qwt_polar_layout.cpp
        src/qwt_polar_magnifier.cpp
        src/qwt_polar_marker.cpp
        src/qwt_polar_panner.cpp
        src/qwt_polar_picker.cpp
        src/qwt_polar_plot.cpp
        src/qwt_polar_renderer.cpp
        src/qwt_polar_spectrogram.cpp
    )
endif()

if(WITH_WIDGETS)
    list(APPEND QWT_HEADERS
        src/qwt_abstract_slider.h
        src/qwt_abstract_scale.h
        src/qwt_arrow_button.h
        src/qwt_analog_clock.h
        src/qwt_compass.h
        src/qwt_compass_rose.h
        src/qwt_counter.h
        src/qwt_dial.h
        src/qwt_dial_needle.h
        src/qwt_knob.h
        src/qwt_slider.h
        src/qwt_thermo.h
        src/qwt_wheel.h
    )
    list(APPEND QWT_SOURCES
        src/qwt_abstract_slider.cpp
        src/qwt_abstract_scale.cpp
        src/qwt_arrow_button.cpp
        src/qwt_analog_clock.cpp
        src/qwt_compass.cpp
        src/qwt_compass_rose.cpp
        src/qwt_counter.cpp
        src/qwt_dial.cpp
        src/qwt_dial_needle.cpp
        src/qwt_knob.cpp
        src/qwt_slider.cpp
        src/qwt_thermo.cpp
        src/qwt_wheel.cpp
    )
endif()

target_sources(qwt PRIVATE
    ${QWT_HEADERS}
    ${QWT_SOURCES}
)

target_include_directories(qwt
    PUBLIC
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_compile_definitions(qwt
    PUBLIC
        $<$<BOOL:${BUILD_DLL}>:QWT_DLL>
    PRIVATE
        $<$<BOOL:${BUILD_DLL}>:QWT_MAKEDLL>
        QWT_MOC_INCLUDE
)

target_link_libraries(qwt
    PUBLIC
    Qt6::Core
    Qt6::OpenGL
    Qt6::Svg
    Qt6::Concurrent
    Qt6::PrintSupport
    Qt6::OpenGLWidgets
)

set_target_properties(qwt PROPERTIES
    AUTOMOC ON
)

install(
    TARGETS qwt
    EXPORT qwt-config
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(FILES ${QWT_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/qwt)
install(EXPORT qwt-config NAMESPACE unofficial::qwt:: DESTINATION share/qwt)