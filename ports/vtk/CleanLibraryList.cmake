# - A smarter replacement for list(REMOVE_DUPLICATES) for library lists
#
# Note that, in the case of cyclic link dependencies, you _do_ actually need
# a library in a list multiple times. So, only use this function when you know
# that the dependency graph is acyclic.
#
#  clean_library_list(<listvar> <_default>) - where
#  listvar is the name of a destination variable, and the the source, and
#  it is followed by either "debug", "optimized" or "general" which will be
#  applied to libraries without any prefix.
#
# Removes duplicates from the list, leaving only the last instance, while
# preserving the meaning of the "optimized", "debug", and "general" labeling.
# (Libraries listed as general are listed in the result instead as optimized and
# debug)
#
# Requires CMake 2.6 or newer (uses the 'function' command)
#
# Original Author:
# 2009-2010 Ryan Pavlik <rpavlik@iastate.edu> <abiryan@ryand.net>
# http://academic.cleardefinition.com
# Iowa State University HCI Graduate Program/VRAC
#
# Copyright Iowa State University 2009-2010.
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)

if(__clean_library_list)
	return()
endif()
set(__clean_library_list YES)

function(clean_library_list _var _default)
	set(_work ${${_var}})
	if(_work)
		# Turn each of optimized, debug, and general into flags
		# prefixed on their respective library (combining list items)
		string(REGEX REPLACE "optimized;" "1CLL%O%" _work "${_work}")
		string(REGEX REPLACE "debug;" "1CLL%D%" _work "${_work}")
		string(REGEX REPLACE "general;" "1CLL%G%" _work "${_work}")

		# Any library that doesn't have a prefix is _default, and a general
		# library is both debug and optimized so stdize it
		set(_std)
		foreach(_lib ${_work})
			if(NOT "${_lib}" MATCHES "^1CLL%.%")
				if("${_default}" STREQUAL "optimized")
					list(APPEND _std "1CLL%O%${_lib}")
				elseif("${_default}" STREQUAL "debug")
					list(APPEND _std "1CLL%D%${_lib}")
				else()
					list(APPEND _std "1CLL%D%${_lib}" "1CLL%O%${_lib}")
				endif()
			elseif("${_lib}" MATCHES "^1CLL%G%")
				string(REPLACE "1CLL%G%" "" _justlib "${_lib}")
				list(APPEND _std "1CLL%D%${_justlib}" "1CLL%O%${_justlib}")
			else()
				list(APPEND _std "${_lib}")
			endif()
		endforeach()

		# REMOVE_DUPLICATES leaves the first - so we reverse before and after
		# to keep the last, instead
		list(REVERSE _std)
		list(REMOVE_DUPLICATES _std)
		list(REVERSE _std)

		# Split list items back out again: turn prefixes into the
		# library type flags.
		string(REGEX REPLACE "1CLL%D%" "debug;" _std "${_std}")
		string(REGEX REPLACE "1CLL%O%" "optimized;" _std "${_std}")

		# Return _std
		set(${_var} ${_std} PARENT_SCOPE)
	endif()
endfunction()
