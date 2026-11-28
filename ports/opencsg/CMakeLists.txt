cmake_minimum_required(VERSION 3.10)
project(opencsg)

find_package(OpenGL REQUIRED)

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
	src/glad/src/gl.cpp
)

add_library(opencsg ${SRCS} ${HEADERS})

target_include_directories(opencsg PRIVATE src src/glad/include include RenderTexture ".")
target_link_libraries(opencsg PRIVATE OpenGL::GL)

install(
  TARGETS opencsg
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

if(NOT DISABLE_INSTALL_HEADERS)
	install(FILES ${HEADERS} DESTINATION include/opencsg)
endif()