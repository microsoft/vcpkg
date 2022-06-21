cmake_minimum_required(VERSION 3.3.0)

project( convectionkernels )

file(GLOB SRC_FILES *.cpp)
file(GLOB HDR_FILES *.h)
add_library( ${PROJECT_NAME}
    STATIC
    ${HDR_FILES}
    ${SRC_FILES}
)
set_property( TARGET ${PROJECT_NAME}
    PROPERTY PUBLIC_HEADER ${HDR_FILES}
)
target_include_directories( ${PROJECT_NAME}
    PRIVATE ${CMAKE_CURRENT_LIST_DIR}
    INTERFACE $<INSTALL_INTERFACE:include>
)
install( TARGETS ${PROJECT_NAME}
    EXPORT unofficial-convectionkernels-config
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    PUBLIC_HEADER DESTINATION include/convectionkernels
)
install( EXPORT unofficial-convectionkernels-config
    FILE unofficial-convectionkernels-config.cmake
    NAMESPACE unofficial::convectionkernels::
    DESTINATION share/unofficial-convectionkernels
)
