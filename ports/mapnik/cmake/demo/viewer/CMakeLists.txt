add_executable(mapnik-viewer 
    about_dialog.cpp
    info_dialog.cpp
    layerdelegate.cpp
    layerlistmodel.cpp
    layerwidget.cpp
    layer_info_dialog.cpp
    main.cpp
    mainwindow.cpp
    mapwidget.cpp
    styles_model.cpp
    
    forms/about.ui
    forms/info.ui
    forms/layer_info.ui    
    
    mapnik_viewer.qrc)

set_target_properties(mapnik-viewer PROPERTIES
    AUTOUIC_SEARCH_PATHS forms
    AUTORCC ON    
    AUTOUIC ON
    AUTOMOC ON)
    
add_dependencies(mapnik-viewer mapnik)
target_link_libraries(mapnik-viewer PRIVATE mapnik Qt5::Widgets)
install(TARGETS mapnik-viewer DESTINATION bin)