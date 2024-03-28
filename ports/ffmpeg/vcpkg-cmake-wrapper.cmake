set(FFMPEG_PREV_MODULE_PATH ${CMAKE_MODULE_PATH})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

cmake_policy(SET CMP0012 NEW)

set(vcpkg_no_avcodec_target ON)
if(TARGET FFmpeg::avcodec)
  set(vcpkg_no_avcodec_target OFF)
endif()

_find_package(${ARGS})

if(@WITH_MP3LAME@)
  _find_package(mp3lame CONFIG REQUIRED)
  list(APPEND FFMPEG_LIBRARIES mp3lame::mp3lame)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    # target exists after find_package and wasn't defined before
    target_link_libraries(FFmpeg::avcodec INTERFACE mp3lame::mp3lame)
  endif()
endif()

set(FFMPEG_LIBRARY ${FFMPEG_LIBRARIES})

set(CMAKE_MODULE_PATH ${FFMPEG_PREV_MODULE_PATH})
