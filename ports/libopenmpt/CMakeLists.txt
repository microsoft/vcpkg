cmake_minimum_required(VERSION 3.9)
project(libopenmpt)

if(MSVC)
  add_compile_options(
    /W3 /wd4005 /wd4267 /wd4244 /wd4996 /wd4100 /wd4018
    -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE
    -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_WARNINGS
  )
endif()

find_package(ZLIB REQUIRED)

find_path(MPG123_INCLUDE_DIR NAMES mpg123.h)
find_library(MPG123_LIBRARY  NAMES mpg123 libmpg123)

find_path(VORBIS_INCLUDE_DIR vorbis/vorbisfile.h)
find_path(OGG_INCLUDE_DIR ogg/ogg.h)

find_library(OGG_LIBRARY NAMES ogg)
find_library(VORBIS_LIBRARY NAMES vorbis)
find_library(VORBISFILE_LIBRARY NAMES vorbisfile)

find_path(FLAC_INCLUDE_DIR FLAC/all.h)
find_library(FLAC_LIBRARY NAMES FLAC flac)

find_path(PORTAUDIO_INCLUDE_DIR NAMES portaudio.h)
find_library(PORTAUDIO_LIBRARY NAMES portaudio)

set(
  lib_headers
  libopenmpt/libopenmpt.h
  libopenmpt/libopenmpt.hpp
  libopenmpt/libopenmpt_config.h
  libopenmpt/libopenmpt_ext.h
  libopenmpt/libopenmpt_ext.hpp
  libopenmpt/libopenmpt_ext_impl.hpp
  libopenmpt/libopenmpt_impl.hpp
  libopenmpt/libopenmpt_internal.h
  libopenmpt/libopenmpt_stream_callbacks_buffer.h
  libopenmpt/libopenmpt_stream_callbacks_fd.h
  libopenmpt/libopenmpt_stream_callbacks_file.h
  libopenmpt/libopenmpt_version.h
)

include_directories(
  .
  build/svn_version
  libopenmpt
  common
  soundbase
  sounddsp
  soundlib
  openmpt123
  ${MPG123_INCLUDE_DIR}
  ${VORBIS_INCLUDE_DIR}
  ${OGG_INCLUDE_DIR}
  ${FLAC_INCLUDE_DIR}
  ${PORTAUDIO_INCLUDE_DIR}
)

set(
  lib_sources
  common/ComponentManager.cpp
  common/FileReader.cpp
  common/Logging.cpp
  common/Profiler.cpp
  common/misc_util.cpp
  common/mptCPU.cpp
  common/mptFileIO.cpp
  common/mptIO.cpp
  common/mptLibrary.cpp
  common/mptOS.cpp
  common/mptPathString.cpp
  common/mptRandom.cpp
  common/mptString.cpp
  common/mptStringFormat.cpp
  common/mptStringParse.cpp
  common/mptTime.cpp
  common/mptUUID.cpp
  common/mptWine.cpp
  common/serialization_utils.cpp
  common/stdafx.cpp
  common/typedefs.cpp
  common/version.cpp
  libopenmpt/libopenmpt_c.cpp
  libopenmpt/libopenmpt_cxx.cpp
  libopenmpt/libopenmpt_ext_impl.cpp
  libopenmpt/libopenmpt_impl.cpp
  sounddsp/AGC.cpp
  sounddsp/DSP.cpp
  sounddsp/EQ.cpp
  sounddsp/Reverb.cpp
  soundlib/AudioCriticalSection.cpp
  soundlib/ContainerMMCMP.cpp
  soundlib/ContainerPP20.cpp
  soundlib/ContainerUMX.cpp
  soundlib/ContainerXPK.cpp
  soundlib/Dither.cpp
  soundlib/Dlsbank.cpp
  soundlib/Fastmix.cpp
  soundlib/ITCompression.cpp
  soundlib/ITTools.cpp
  soundlib/InstrumentExtensions.cpp
  soundlib/Load_669.cpp
  soundlib/Load_amf.cpp
  soundlib/Load_ams.cpp
  soundlib/Load_dbm.cpp
  soundlib/Load_digi.cpp
  soundlib/Load_dmf.cpp
  soundlib/Load_dsm.cpp
  soundlib/Load_dtm.cpp
  soundlib/Load_far.cpp
  soundlib/Load_gdm.cpp
  soundlib/Load_imf.cpp
  soundlib/Load_it.cpp
  soundlib/Load_itp.cpp
  soundlib/Load_mdl.cpp
  soundlib/Load_med.cpp
  soundlib/Load_mid.cpp
  soundlib/Load_mo3.cpp
  soundlib/Load_mod.cpp
  soundlib/Load_mt2.cpp
  soundlib/Load_mtm.cpp
  soundlib/Load_okt.cpp
  soundlib/Load_plm.cpp
  soundlib/Load_psm.cpp
  soundlib/Load_ptm.cpp
  soundlib/Load_s3m.cpp
  soundlib/Load_sfx.cpp
  soundlib/Load_stm.cpp
  soundlib/Load_stp.cpp
  soundlib/Load_uax.cpp
  soundlib/Load_ult.cpp
  soundlib/Load_wav.cpp
  soundlib/Load_xm.cpp
  soundlib/MIDIEvents.cpp
  soundlib/MIDIMacros.cpp
  soundlib/MPEGFrame.cpp
  soundlib/Message.cpp
  soundlib/MixFuncTable.cpp
  soundlib/MixerLoops.cpp
  soundlib/MixerSettings.cpp
  soundlib/ModChannel.cpp
  soundlib/ModInstrument.cpp
  soundlib/ModSample.cpp
  soundlib/ModSequence.cpp
  soundlib/OggStream.cpp
  soundlib/Paula.cpp
  soundlib/RowVisitor.cpp
  soundlib/S3MTools.cpp
  soundlib/SampleFormatFLAC.cpp
  soundlib/SampleFormatMP3.cpp
  soundlib/SampleFormatMediaFoundation.cpp
  soundlib/SampleFormatOpus.cpp
  soundlib/SampleFormatVorbis.cpp
  soundlib/SampleFormats.cpp
  soundlib/SampleIO.cpp
  soundlib/Snd_flt.cpp
  soundlib/Snd_fx.cpp
  soundlib/Sndfile.cpp
  soundlib/Sndmix.cpp
  soundlib/SoundFilePlayConfig.cpp
  soundlib/Tables.cpp
  soundlib/Tagging.cpp
  soundlib/UMXTools.cpp
  soundlib/UpgradeModule.cpp
  soundlib/WAVTools.cpp
  soundlib/WindowedFIR.cpp
  soundlib/XMTools.cpp
  soundlib/load_j2b.cpp
  soundlib/mod_specifications.cpp
  soundlib/modcommand.cpp
  soundlib/modsmp_ctrl.cpp
  soundlib/pattern.cpp
  soundlib/patternContainer.cpp
  soundlib/plugins/DigiBoosterEcho.cpp
  soundlib/plugins/LFOPlugin.cpp
  soundlib/plugins/PlugInterface.cpp
  soundlib/plugins/PluginManager.cpp
  soundlib/plugins/dmo/Chorus.cpp
  soundlib/plugins/dmo/Compressor.cpp
  soundlib/plugins/dmo/DMOPlugin.cpp
  soundlib/plugins/dmo/Distortion.cpp
  soundlib/plugins/dmo/Echo.cpp
  soundlib/plugins/dmo/Flanger.cpp
  soundlib/plugins/dmo/Gargle.cpp
  soundlib/plugins/dmo/I3DL2Reverb.cpp
  soundlib/plugins/dmo/ParamEq.cpp
  soundlib/plugins/dmo/WavesReverb.cpp
  soundlib/tuning.cpp
  soundlib/tuningCollection.cpp
  soundlib/tuningbase.cpp
)

add_library(libopenmpt ${lib_sources})

target_compile_definitions(libopenmpt PRIVATE
  -DMPT_WITH_MPG123 -DMPT_WITH_OGG
  -DMPT_WITH_VORBIS -DMPT_WITH_VORBISFILE
  -DMPT_WITH_ZLIB -DMPT_BUILD_VCPKG
  -DLIBOPENMPT_BUILD
)

set(cli_srcs openmpt123/openmpt123.cpp)

add_executable(openmpt123 ${cli_srcs})

target_compile_definitions(openmpt123 PRIVATE
  -DMPT_WITH_MPG123 -DMPT_WITH_OGG
  -DMPT_WITH_VORBIS -DMPT_WITH_VORBISFILE
  -DMPT_WITH_ZLIB -DMPT_BUILD_VCPKG
  -DLIBOPENMPT_BUILD
)



if(BUILD_SHARED_LIBS)
  target_compile_definitions(
    libopenmpt
    PRIVATE
    -DMPT_BUILD_MSVC_SHARED -DLIBOPENMPT_BUILD_DLL
  )
  target_compile_definitions(
    openmpt123
    PRIVATE
    -DMPT_BUILD_MSVC_SHARED -DLIBOPENMPT_BUILD_DLL
  )
else()
  target_compile_definitions(
    libopenmpt
    PRIVATE
    -DMPT_BUILD_MSVC_STATIC
  )
  target_compile_definitions(
    openmpt123
    PRIVATE
    -DMPT_BUILD_MSVC_STATIC
  )
endif()

target_link_libraries(
  libopenmpt
  PRIVATE
  ${OGG_LIBRARY}
  ${MPG123_LIBRARY}
  ${VORBISFILE_LIBRARY}
  ${VORBIS_LIBRARY}
  ${VORBISFILE_LIBRARY}
  ZLIB::ZLIB
)

target_link_libraries(
  openmpt123
  PRIVATE
  libopenmpt
  ${OGG_LIBRARY}
  ${MPG123_LIBRARY}
  ${VORBISFILE_LIBRARY}
  ${VORBIS_LIBRARY}
  ${VORBISFILE_LIBRARY}
  ${FLAC_LIBRARY}
  ${PORTAUDIO_LIBRARY}
  Winmm
  ZLIB::ZLIB
)
install(
  TARGETS libopenmpt
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES ${lib_headers} DESTINATION include/libopenmpt)
endif()

if(NOT DISABLE_INSTALL_TOOLS)
  install (
    TARGETS openmpt123
    RUNTIME DESTINATION tools/libopenmpt
  )
endif()
