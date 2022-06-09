cmake_minimum_required(VERSION 3.3.0)

project( cvtt )

set( SRC_FILES
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_API.cpp
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_BC6H_IO.cpp
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_BC7_PrioData.cpp
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_BC67.cpp
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_BCCommon.cpp
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_ETC.cpp
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_IndexSelector.cpp
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_S3TC.cpp
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_Util.cpp
)
set( HDR_FILES
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_AggregatedError.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_BC6H_IO.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_BC7_Prio.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_BC7_SingleColor.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_BC67.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_BCCommon.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_EndpointRefiner.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_EndpointSelector.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_ETC.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_ETC1.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_ETC2.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_ETC2_Rounding.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_FakeBT709_Rounding.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_IndexSelector.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_IndexSelectorHDR.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_PackedCovarianceMatrix.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_ParallelMath.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_S3TC.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_S3TC_SingleColor.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_UnfinishedEndpoints.h
    ${CMAKE_CURRENT_LIST_DIR}/ConvectionKernels_Util.h
)
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
    EXPORT unofficial-cvtt-config
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    PUBLIC_HEADER DESTINATION include/cvtt
)
install( EXPORT unofficial-cvtt-config
    FILE unofficial-cvtt-config.cmake
    NAMESPACE unofficial::cvtt::
    DESTINATION share/unofficial-cvtt
)
