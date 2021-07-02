cmake_minimum_required(VERSION 3.8)
project(recast)

set(SRC
  DebugUtils/Source/DebugDraw.cpp
  DebugUtils/Source/DetourDebugDraw.cpp
  DebugUtils/Source/RecastDebugDraw.cpp
  DebugUtils/Source/RecastDump.cpp
  Detour/Source/DetourAlloc.cpp
  Detour/Source/DetourCommon.cpp
  Detour/Source/DetourNavMesh.cpp
  Detour/Source/DetourNavMeshBuilder.cpp
  Detour/Source/DetourNavMeshQuery.cpp
  Detour/Source/DetourNode.cpp
  DetourCrowd/Source/DetourCrowd.cpp
  DetourCrowd/Source/DetourLocalBoundary.cpp
  DetourCrowd/Source/DetourObstacleAvoidance.cpp
  DetourCrowd/Source/DetourPathCorridor.cpp
  DetourCrowd/Source/DetourPathQueue.cpp
  DetourCrowd/Source/DetourProximityGrid.cpp
  DetourTileCache/Source/DetourTileCache.cpp
  DetourTileCache/Source/DetourTileCacheBuilder.cpp
  Recast/Source/Recast.cpp
  Recast/Source/RecastAlloc.cpp
  Recast/Source/RecastArea.cpp
  Recast/Source/RecastContour.cpp
  Recast/Source/RecastFilter.cpp
  Recast/Source/RecastLayers.cpp
  Recast/Source/RecastMesh.cpp
  Recast/Source/RecastMeshDetail.cpp
  Recast/Source/RecastRasterization.cpp
  Recast/Source/RecastRegion.cpp
)

add_library(recast ${SRC})

target_include_directories(
  recast PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/DebugUtils/Include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Detour/Include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/DetourCrowd/Include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/DetourTileCache/Include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Recast/Include>
  $<INSTALL_INTERFACE:include>
  $<INSTALL_INTERFACE:include/Detour/Include>
  $<INSTALL_INTERFACE:include/DetourCrowd/Include>
  $<INSTALL_INTERFACE:include/DetourTileCache/Include>
  $<INSTALL_INTERFACE:include/Recast/Include>
  $<INSTALL_INTERFACE:include/DebugUtils/Include>
)

install(
  TARGETS recast
  EXPORT unofficial-recast-config
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(EXPORT unofficial-recast-config DESTINATION share/unofficial-recast)

if(NOT DISABLE_INSTALL_HEADERS)
  install(DIRECTORY DebugUtils/Include/ DESTINATION include/recast/DebugUtils)
  install(DIRECTORY Detour/Include/ DESTINATION include/recast/Detour)
  install(DIRECTORY DetourCrowd/Include/ DESTINATION include/recast/DetourCrowd)
  install(DIRECTORY DetourTileCache/Include/ DESTINATION include/recast/DetourTileCache)
  install(DIRECTORY Recast/Include/ DESTINATION include/recast/Recast)
endif()
