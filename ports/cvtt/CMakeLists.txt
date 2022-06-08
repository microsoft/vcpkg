cmake_minimum_required(VERSION 3.3.0)

project( cvtt )

set( ${PROJECT_NAME}_SRC_FILES
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
set( ${PROJECT_NAME}_HDR_FILES
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
source_group( "Header Files" FILES ${${PROJECT_NAME}_HDR_FILES} )
source_group( "Source Files" FILES ${${PROJECT_NAME}_SRC_FILES} )
add_library(
    ${PROJECT_NAME}
    STATIC
    ${${PROJECT_NAME}_HDR_FILES}
    ${${PROJECT_NAME}_SRC_FILES}
)
add_library( cvtt::${PROJECT_NAME}
    ALIAS
    ${PROJECT_NAME}
)
target_include_directories( ${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
)
install(
    TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION "bin"
    LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib"
)
if (NOT DEFINED SKIP_HEADERS)
    install(
        FILES ${${PROJECT_NAME}_HDR_FILES}
        DESTINATION include/cvtt
    )
endif()

install(
    TARGETS cvtt
    COMPONENT cvtt
    EXPORT cvtt
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
install( EXPORT cvtt
    FILE cvttConfig.cmake
    COMPONENT cvtt
    NAMESPACE cvtt::
    DESTINATION lib/cmake/cvtt
)
