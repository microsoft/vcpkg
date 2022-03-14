cmake_minimum_required(VERSION 3.12)

project(PoissonRecon LANGUAGES NONE)

set(INSTALL_BIN_DIR      "bin"                     CACHE PATH "Path where exe and dll will be installed")
set(INSTALL_LIB_DIR      "lib"                     CACHE PATH "Path where lib will be installed")
set(INSTALL_INCLUDE_DIR  "include/${PROJECT_NAME}" CACHE PATH "Path where headers will be installed")
set(INSTALL_CMAKE_DIR    "share/poissonrecon"   CACHE PATH "Path where cmake configs will be installed")

find_package(PNG REQUIRED)
find_package(JPEG REQUIRED)

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
"Src/Polynomial.h"
"Src/PPolynomial.h"
"Src/PreProcessor.h"
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
"Src/Polynomial.inl"
"Src/PPolynomial.inl"
"Src/RegularTree.inl"
"Src/SparseMatrix.inl"
"Src/SparseMatrixInterface.inl"
"Src/Window.inl"
)

add_library(PoissonRecon INTERFACE)
target_link_libraries(PoissonRecon INTERFACE PNG::PNG JPEG::JPEG)
set_target_properties(PoissonRecon PROPERTIES PUBLIC_HEADER "${PoissonRecon_HEADERS};${PoissonRecon_INLINES}")
target_include_directories(PoissonRecon INTERFACE $<INSTALL_INTERFACE:${INSTALL_INCLUDE_DIR}>)

install(TARGETS PoissonRecon EXPORT PoissonReconTargets
  RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
  LIBRARY DESTINATION "${INSTALL_LIB_DIR}"
  ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
  PUBLIC_HEADER DESTINATION "${INSTALL_INCLUDE_DIR}"
)
install(EXPORT PoissonReconTargets
  NAMESPACE PoissonRecon::
  DESTINATION ${INSTALL_CMAKE_DIR}
)
