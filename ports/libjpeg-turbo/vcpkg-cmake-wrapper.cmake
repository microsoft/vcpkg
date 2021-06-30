find_package(libjpeg-turbo CONFIG)

# Find a target
foreach (_TARGET libjpeg-turbo::jpeg-static libjpeg-turbo::jpeg)
  if (TARGET _TARGET)
    add_library(JPEG::JPEG ALIAS ${_TARGET})
  endif()
endforeach (_TARGET)
