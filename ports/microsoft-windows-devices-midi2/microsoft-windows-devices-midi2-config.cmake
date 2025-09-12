cmake_minimum_required (VERSION 3.30)

set(MIDI2_WINMD "@MIDI_SDK_EXTRACTED_FILES@/ref/native/Microsoft.Windows.Devices.Midi2.winmd")

message("-MIDI: adding include: @MIDI_SDK_EXTRACTED_FILES@/build/native/include")
message("-MIDI: adding include: @WINRT_GENERATED_HEADERS_FOLDER@")


# run the cppwinrt tool against the winmd in our extracted archive
# this requires that it was installed and configured before MIDI was configured

if (EXISTS "${CPPWINRT_TOOL}")
  message(STATUS "-MIDI: Generating Microsoft.Windows.Devices.Midi2 headers.")

  execute_process(
      COMMAND "${CPPWINRT_TOOL}"
          -include "Microsoft.Windows.Devices.Midi2"
          -reference "@WINDOWS_SDK_VERSION@"
          -reference "${MIDI2_WINMD}"
          -output "@WINRT_GENERATED_HEADERS_FOLDER@"
          -overwrite
          -optimize
          -verbose
  )
else()
  message(FATAL_ERROR "-MIDI: Variable CPPWINRT_TOOL not set. This needs to be set to the value of CPPWINRT_TOOL variable after cppwinrt configure has run")
endif()


# this is needed for the initialization hpp file and the version include file
include_directories("@MIDI_SDK_EXTRACTED_FILES@/build/native/include")
include_directories("@WINRT_GENERATED_HEADERS_FOLDER@")
