########################################################################
# cet_copy
#
# Simple internal copy target to avoid triggering a CMake when files
# have changed.
#
# Usage: cet_copy(<sources>... DESTINATION <dir> [options])
#
####################################
# Options:
#
# DEPENDENCIES <deps>...
#
#   If any <deps> change, the file shall be re-copied (the source file
#   itself is always a dependency).
#
# NAME
#
#   New name for the file in its final destination.
#
# NAME_AS_TARGET
#
#   Use the basename of the file as the target for the copy operation,
#   in order to facilitate dependency references. This non-default
#   option has the caveat that it is left to the package author to
#   ensure that there are no name collisions.
#
# PROGRAMS
#
#   Copied files should be made executable.
#
# WORKING_DIRECTORY <dir>
#
#   Paths are relative to the specified directory (default
#   CMAKE_CURRENT_BINARY_DIR).
#
####################################
# Notes
#
# For PROGRAMS, custom commands using them will be updated when the
# program changes if one lists the script in the DEPENDS list of the
# custom command.
########################################################################
include(CMakeParseArguments)

function(cet_copy)
  cmake_parse_arguments(CETC
    "PROGRAMS;NAME_AS_TARGET"
    "DESTINATION;NAME;WORKING_DIRECTORY"
    "DEPENDENCIES"
    ${ARGN})

  if(NOT CETC_DESTINATION)
    message(FATAL_ERROR "Missing required option argument DESTINATION")
  endif()

  if(NOT CETC_WORKING_DIRECTORY)
    set(CETC_WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
  endif()

  foreach(source ${CETC_UNPARSED_ARGUMENTS})
    if(CETC_NAME)
      set(dest_path "${CETC_DESTINATION}/${CETC_NAME}")
    else()
      get_filename_component(source_base "${source}" NAME)
      set(dest_path "${CETC_DESTINATION}/${source_base}")
    endif()

    if(CETC_NAME_AS_TARGET)
      get_filename_component(target ${dest_path} NAME)
    else()
      string(FIND "${dest_path}" "${PROJECT_BINARY_DIR}" abs_build_found)
      if(abs_build_found EQUAL 0)
        string(LENGTH "${PROJECT_BINARY_DIR}" abs_build_len)
        string(SUBSTRING "${dest_path}" ${abs_build_len} -1 dest_path_target)
        string(REPLACE "/" "+" target "${dest_path_target}")
      else()
        string(REPLACE "/" "+" target "${dest_path}")
    endif()

    string(REGEX REPLACE "[: ]" "+" target "${target}")

    add_custom_command(OUTPUT "${dest_path}"
      WORKING_DIRECTORY "${CETC_WORKING_DIRECTORY}"
      COMMAND ${CMAKE_COMMAND} -E make_directory "${CETC_DESTINATION}"
      COMMAND ${CMAKE_COMMAND} -E copy "${source}" "${dest_path}"
      COMMENT "Copying ${source} to ${dest_path}"
      DEPENDS "${source}" ${CETC_DEPENDENCIES}
      )

    # If it's pure copy, then file should probably be executable already.
    if(CETC_PROGRAMS)
      add_custom_command(OUTPUT "${dest_path}"
        COMMAND chmod +x "${dest_path}"
        APPEND
        )
    endif()
    add_custom_target(${target} ALL DEPENDS "${dest_path}")
  endforeach()
endfunction()
