cmake_minimum_required (VERSION 3.4)
project (opencsg)

set(HEADERS
  include/opencsg.h
)

set(SRCS
	src/area.cpp
	src/batch.cpp
	src/context.cpp
	src/channelManager.cpp
	src/frameBufferObject.cpp
	src/frameBufferObjectExt.cpp
	src/occlusionQuery.cpp
	src/opencsgRender.cpp
	src/openglHelper.cpp
	src/primitive.cpp
	src/primitiveHelper.cpp
	src/renderGoldfeather.cpp
	src/renderSCS.cpp
	src/scissorMemo.cpp
	src/settings.cpp
	src/stencilManager.cpp
	src/pBufferTexture.cpp
	RenderTexture/RenderTexture.cpp
)


add_library(opencsg ${SRCS} ${HEADERS})

include_directories(src include RenderTexture ".")
find_package(GLEW REQUIRED)
include_directories(${GLEW_INCLUDE_DIRS})
target_link_libraries(opencsg PRIVATE GLEW::GLEW)

install(
  TARGETS opencsg
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

if(NOT DISABLE_INSTALL_HEADERS)
	install(FILES ${HEADERS} DESTINATION include/opencsg)
endif()
