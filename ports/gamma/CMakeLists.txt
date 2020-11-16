cmake_minimum_required (VERSION 3.0)

project (gamma)

# dependent on libsndfile and portaudio
find_package(SndFile CONFIG REQUIRED)
find_path(PORTAUDIO_H portaudio.h)
find_library(PORTAUDIO_LIB NAMES portaudio)

set(SOURCEFILES
        src/arr.cpp
        src/AudioIO.cpp
        src/Conversion.cpp
        src/Domain.cpp
        src/DFT.cpp
        src/FFT_fftpack.cpp
        src/fftpack++1.cpp
        src/fftpack++2.cpp
        src/SoundFile.cpp
        src/Print.cpp
        src/Recorder.cpp
        src/scl.cpp
        src/Scheduler.cpp
        src/Timer.cpp
        src/SoundFile.cpp)

include_directories(. Gamma ${CMAKE_INSTALL_FULL_INCLUDEDIR} ${PORTAUDIO_H})

add_library (gamma ${SOURCEFILES})
target_link_libraries(gamma PUBLIC SndFile::sndfile ${PORTAUDIO_LIB})

install(
  TARGETS gamma
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
    install(DIRECTORY Gamma DESTINATION include FILES_MATCHING PATTERN "*.h")
endif()
