find_path(
    LIBUSB_INCLUDE_DIRS
    NAMES libusb.h
    PATH_SUFFIXES libusb-1.0
)

find_library(
    LIBUSB_LIBRARIES
    NAMES libusb-1.0
)

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(
    LIBUSB
    REQUIRED_VARS LIBUSB_LIBRARIES LIBUSB_INCLUDE_DIRS
)
