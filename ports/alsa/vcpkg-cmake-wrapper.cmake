find_path(
  ALSA_INCLUDE_DIR
  NAMES alsa/asoundlib.h
  PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
  NO_DEFAULT_PATH
)

find_library(
  ALSA_LIBRARY_DEBUG
  NAMES asound
  PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib"
  NO_DEFAULT_PATH
)

find_library(
  ALSA_LIBRARY_RELEASE
  NAMES asound
  PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib"
  NO_DEFAULT_PATH
)

include(SelectLibraryConfigurations)
select_library_configurations(ALSA)
unset(ALSA_FOUND)

if(NOT ALSA_INCLUDE_DIR OR NOT ALSA_LIBRARY)
  message(FATAL_ERROR "Broken installation of the alsa vcpkg port")
endif()

_find_package(${ARGS})

if(TARGET ALSA::ALSA)
  if(ALSA_LIBRARY_DEBUG)
    set_property(
      TARGET ALSA::ALSA
      APPEND
      PROPERTY IMPORTED_CONFIGURATIONS DEBUG
    )
    set_target_properties(
      ALSA::ALSA
      PROPERTIES
        IMPORTED_LOCATION_DEBUG "${ALSA_LIBRARY_DEBUG}"
    )
  endif()
  if(ALSA_LIBRARY_RELEASE)
    set_property(
      TARGET ALSA::ALSA
      APPEND
      PROPERTY IMPORTED_CONFIGURATIONS RELEASE
    )
    set_target_properties(
      ALSA::ALSA
      PROPERTIES
        IMPORTED_LOCATION_RELEASE "${ALSA_LIBRARY_RELEASE}"
    )
  endif()

  find_library(Z_VCPKG_HAS_LIBM NAMES m)
  if(Z_VCPKG_HAS_LIBM)
    list(APPEND ALSA_LIBRARIES m)
    set_property(
      TARGET ALSA::ALSA
      APPEND
      PROPERTY INTERFACE_LINK_LIBRARIES m
    )
  endif()

  if(CMAKE_DL_LIBS)
    list(APPEND ALSA_LIBRARIES ${CMAKE_DL_LIBS})
    set_property(
      TARGET ALSA::ALSA
      APPEND
      PROPERTY INTERFACE_LINK_LIBRARIES ${CMAKE_DL_LIBS}
    )
  endif()

  find_package(Threads)
  if(TARGET Threads::Threads)
    list(APPEND ALSA_LIBRARIES Threads::Threads)
    set_property(
      TARGET ALSA::ALSA
      APPEND
      PROPERTY INTERFACE_LINK_LIBRARIES Threads::Threads
    )
  endif()

  find_library(Z_VCPKG_HAS_LIBRT NAMES rt)
  if(Z_VCPKG_HAS_LIBRT)
    list(APPEND ALSA_LIBRARIES rt)
    set_property(
      TARGET ALSA::ALSA
      APPEND
      PROPERTY INTERFACE_LINK_LIBRARIES rt
    )
  endif()
endif()
