cmake_minimum_required (VERSION 3.30)

set(MIDI2_WINDOWS_SDK_VERSION @WINDOWS_SDK_VERSION@)
set(MIDI2_WINRT_WINMD "@MIDI_SDK_EXTRACTED_FILES@/ref/native/Microsoft.Windows.Devices.Midi2.winmd")
set(MIDI2_HEADERS_ROOT_FOLDER @MIDI2_HEADERS_ROOT_FOLDER@)
set(MIDI2_HEADERS_INIT_FOLDER @MIDI2_HEADERS_INIT_FOLDER@)
set(MIDI2_HEADERS_WINRT_FOLDER @MIDI2_HEADERS_WINRT_FOLDER@)

# try to find the cppwinrt.exe tool. An exact path to the CPPWINRT_TOOL can be provided
# by the target build script if there's a specific version it needs. That's also the 
# variable the cppwinrt vcpkg sets when it is configured with find_package.
#
# We hint at the one in the package directory because the version that is in the 
# installed Windows SDK is several revisions older, but is more likely to get
# picked up as it is in the path.
#
# The preferred cppwinrt package is not necessarily available at install time,
# so we run it and build the headers here.

message ("VCPKG_INSTALLED_DIR = ${VCPKG_INSTALLED_DIR}")

if (NOT DEFINED CPPWINRT_TOOL OR "${CPPWINRT_TOOL}" STREQUAL "" OR NOT EXISTS "${CPPWINRT_TOOL}")
  find_program(
    CPPWINRT_TOOL
    NAMES "cppwinrt.exe"
    HINTS "${VCPKG_INSTALLED_DIR}"
    REQUIRED
  )

  message(STATUS "MIDI2: Found cppwinrt.exe here: ${CPPWINRT_TOOL}")
else()
  message(STATUS "MIDI2: Using provided CPPWINRT_TOOL: ${CPPWINRT_TOOL}")
endif()

# run the cppwinrt tool against the winmd in our extracted archive
# this requires that it was installed and configured before MIDI was configured
# We need to use the latest version that is available, from a dependency port

if (EXISTS "${CPPWINRT_TOOL}")
  message(STATUS "MIDI2: Generating Microsoft.Windows.Devices.Midi2 headers.")
  message(STATUS "MIDI2:   Using cppwinrt.exe:   ${CPPWINRT_TOOL}")
  message(STATUS "MIDI2:   Including MIDI winmd: ${MIDI2_WINRT_WINMD}")
  message(STATUS "MIDI2:   Using Windows SDK:    ${MIDI2_WINDOWS_SDK_VERSION}")

  # this will generate projection headers to the "winrt" subfolder of the provided output folder
  execute_process(
      COMMAND_ERROR_IS_FATAL ANY
      COMMAND "${CPPWINRT_TOOL}"
          -include "Microsoft.Windows.Devices.Midi2"
          -reference "${MIDI2_WINDOWS_SDK_VERSION}"
          -reference "${MIDI2_WINRT_WINMD}"
          -output "${MIDI2_HEADERS_ROOT_FOLDER}"
          -overwrite
          -optimize
          -verbose
  )

  # location of the generated WinRT headers for the MIDI SDK
  message(STATUS "MIDI2: MIDI2_WINRT_HEADERS_FOLDER root:          ${MIDI2_HEADERS_ROOT_FOLDER}")
  message(STATUS "MIDI2: MIDI2_HEADERS_WINRT_FOLDER Projections:   ${MIDI2_HEADERS_WINRT_FOLDER}")
  message(STATUS "MIDI2: MIDI2_HEADERS_INIT_FOLDER Bootstrap/init: ${MIDI2_HEADERS_INIT_FOLDER}")

else()
  message(FATAL_ERROR "MIDI2: Variable CPPWINRT_TOOL not set. The cppwinrt.exe vcpkg needs to be found before installing this package.")
endif()
