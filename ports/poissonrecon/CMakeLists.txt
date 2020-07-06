# Created from 7-zip v19.00 - 7zip/CPP/7zip/Bundles/Format7zF

cmake_minimum_required(VERSION 3.0)

project(PoissonRecon LANGUAGES C CXX)

set(INSTALL_BIN_DIR      "bin"                     CACHE PATH "Path where exe and dll will be installed")
set(INSTALL_LIB_DIR      "lib"                     CACHE PATH "Path where lib will be installed")
set(INSTALL_INCLUDE_DIR  "include/${PROJECT_NAME}" CACHE PATH "Path where headers will be installed")
set(INSTALL_CMAKE_DIR    "share/${PROJECT_NAME}"   CACHE PATH "Path where cmake configs will be installed")

option(BUILD_TOOLS "Build PoissonRecon tools" ON)

find_package (PNG REQUIRED)
find_package(JPEG REQUIRED)

if(MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj")
endif()

if(BUILD_TOOLS)
    add_executable(PoissonReconEXE "Src/PoissonRecon.cpp")
    target_link_libraries(PoissonReconEXE PRIVATE png ${JPEG_LIBRARIES})
    target_include_directories(PoissonReconEXE PRIVATE ${JPEG_INCLUDE_DIR})
    target_compile_definitions(PoissonReconEXE PRIVATE -DNOMINMAX -D_CRT_SECURE_NO_WARNINGS)
    add_executable(SSDRecon "Src/SSDRecon.cpp")
    target_link_libraries(SSDRecon PRIVATE png ${JPEG_LIBRARIES})
    target_include_directories(SSDRecon PRIVATE ${JPEG_INCLUDE_DIR})
    target_compile_definitions(SSDRecon PRIVATE -DNOMINMAX -D_CRT_SECURE_NO_WARNINGS)
    add_executable(PointInterpolant "Src/PointInterpolant.cpp")
    target_link_libraries(PointInterpolant PRIVATE png ${JPEG_LIBRARIES})
    target_include_directories(PointInterpolant PRIVATE ${JPEG_INCLUDE_DIR})
    target_compile_definitions(PointInterpolant PRIVATE -DNOMINMAX -D_CRT_SECURE_NO_WARNINGS)
    add_executable(SurfaceTrimmer "Src/SurfaceTrimmer.cpp")
    target_link_libraries(SurfaceTrimmer PRIVATE png ${JPEG_LIBRARIES})
    target_include_directories(SurfaceTrimmer PRIVATE ${JPEG_INCLUDE_DIR})
    target_compile_definitions(SurfaceTrimmer PRIVATE -DNOMINMAX -D_CRT_SECURE_NO_WARNINGS)
    add_executable(EDTInHeat "Src/EDTInHeat.cpp")
    target_link_libraries(EDTInHeat PRIVATE png ${JPEG_LIBRARIES})
    target_include_directories(EDTInHeat PRIVATE ${JPEG_INCLUDE_DIR})
    target_compile_definitions(EDTInHeat PRIVATE -DNOMINMAX -D_CRT_SECURE_NO_WARNINGS)
    add_executable(ImageStitching "Src/ImageStitching.cpp")
    target_link_libraries(ImageStitching PRIVATE png ${JPEG_LIBRARIES})
    target_include_directories(ImageStitching PRIVATE ${JPEG_INCLUDE_DIR})
    target_compile_definitions(ImageStitching PRIVATE -DNOMINMAX -D_CRT_SECURE_NO_WARNINGS)
    add_executable(AdaptiveTreeVisualization "Src/AdaptiveTreeVisualization.cpp")
    target_link_libraries(AdaptiveTreeVisualization PRIVATE png ${JPEG_LIBRARIES})
    target_include_directories(AdaptiveTreeVisualization PRIVATE ${JPEG_INCLUDE_DIR})
    target_compile_definitions(AdaptiveTreeVisualization PRIVATE -DNOMINMAX -D_CRT_SECURE_NO_WARNINGS)
    add_executable(ChunkPLY "Src/ChunkPLY.cpp")
    target_link_libraries(ChunkPLY PRIVATE png ${JPEG_LIBRARIES})
    target_include_directories(ChunkPLY PRIVATE ${JPEG_INCLUDE_DIR})
    target_compile_definitions(ChunkPLY PRIVATE -DNOMINMAX -D_CRT_SECURE_NO_WARNINGS)
endif()


set(PoissonRecon_HEADERS
"Src/Allocator.h"
"Src/Array.h"
"Src/BinaryNode.h"
"Src/BlockedVector.h"
"Src/BSplineData.h"
"Src/CmdLineParser.h"
"Src/Factor.h"
"Src/FEMTree.h"
"Src/FunctionData.h"
"Src/Geometry.h"
"Src/Image.h"
"Src/JPEG.h"
"Src/LinearSolvers.h"
"Src/MarchingCubes.h"
"Src/MAT.h"
"Src/MyMiscellany.h"
"Src/Ply.h"
"Src/PlyFile.h"
"Src/PNG.h"
"Src/PointStream.h"
"Src/PointStreamData.h"
"Src/Polynomial.h"
"Src/PPolynomial.h"
"Src/PreProcessor.h"
#"Src/Rasterizer.h"
#"Src/RegularGrid.h"
"Src/RegularTree.h"
"Src/SparseMatrix.h"
"Src/SparseMatrixInterface.h"
"Src/Window.h"
)

set(PoissonRecon_INLINES
"Src/Array.inl"
"Src/BMPStream.inl"
"Src/BSplineData.inl"
"Src/CmdLineParser.inl"
"Src/FEMTree.Evaluation.inl"
"Src/FEMTree.Initialize.inl"
"Src/FEMTree.inl"
"Src/FEMTree.IsoSurface.specialized.inl"
"Src/FEMTree.SortedTreeNodes.inl"
"Src/FEMTree.System.inl"
"Src/FEMTree.WeightedSamples.inl"
"Src/FunctionData.inl"
"Src/Geometry.inl"
"Src/JPEG.inl"
"Src/MAT.inl"
"Src/PlyFile.inl"
"Src/PNG.inl"
"Src/PointStream.inl"
"Src/Polynomial.inl"
"Src/PPolynomial.inl"
#"Src/Rasterizer.inl"
#"Src/RegularGrid.inl"
"Src/RegularTree.inl"
"Src/SparseMatrix.inl"
"Src/SparseMatrixInterface.inl"
"Src/Window.inl"
)

add_library(PoissonRecon INTERFACE)
set_target_properties(PoissonRecon PROPERTIES PUBLIC_HEADER "${PoissonRecon_HEADERS};${PoissonRecon_INLINES}")

install(TARGETS PoissonRecon EXPORT PoissonReconTargets
  RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
  LIBRARY DESTINATION "${INSTALL_LIB_DIR}"
  ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
  PUBLIC_HEADER DESTINATION "${INSTALL_INCLUDE_DIR}"
  COMPONENT dev
)

if(BUILD_TOOLS)
    install(TARGETS PoissonReconEXE SSDRecon PointInterpolant SurfaceTrimmer EDTInHeat ImageStitching AdaptiveTreeVisualization ChunkPLY
      DESTINATION "${INSTALL_BIN_DIR}"
    )
endif()
