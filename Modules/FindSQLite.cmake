#.rst:
# FindSQLite
# ----------
#
# Find the native SQLite includes and libraries
#
# Imported Targets
# ^^^^^^^^^^^^^^^^
#
# If SQLite is found, this module defines the following :cmake:prop_tgt:`IMPORTED`
# targets::
#
#  SQLite::SQLite           - The main SQLite library
#  SQLite::SQLiteExecutable - The main SQlite program
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module wil set the following variables in your project::
#
#  SQLite_FOUND        - True if an install of SQLite is found
#  SQLite_INCLUDE_DIRS - Location of SQLite header files
#  SQLite_LIBRARIES    - The SQLite libraries
#  SQLite_EXECUTABLE   - Path to sqlite executable
#  SQLite_VERSION      - The version of the found SQLite install
#

#=======================================================================
# Copyright (c) 2016, Ben Morgan <Ben.Morgan@warwick.ac.uk>
#
# Distributed under the OSI-approved BSD 3-Clause License (the "License");
# see accompanying file LICENSE for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=======================================================================

# Include the module to handle QUIETLY and REQUIRED arguments
include(FindPackageHandleStandardArgs)

#-----------------------------------------------------------------------
# Find SQLite paths only using defaults for now
find_path(SQLite_INCLUDE_DIR sqlite3.h)
find_library(SQLite_LIBRARY sqlite3)
find_program(SQLite_EXECUTABLE sqlite3)

# If we have the executable, use it to extract the version
if(EXISTS "${SQLite_EXECUTABLE}")
  execute_process(
    COMMAND "${SQLite_EXECUTABLE}" --version
    OUTPUT_VARIABLE SQLite_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  # sqlite3 program outputs "version date time hash"
  # so only take version part
  string(REGEX REPLACE " .*$" "" SQLite_VERSION ${SQLite_VERSION})
endif()

#-----------------------------------------------------------------------
# handle the QUIETLY and REQUIRED arguments and set SQLite_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(SQLite
  FOUND_VAR
    SQLite_FOUND
  REQUIRED_VARS
    SQLite_INCLUDE_DIRS
    SQLite_LIBRARY
  VERSION_VAR
    SQLite_VERSION
    )

mark_as_advanced(SQLite_INCLUDE_DIR SQLite_LIBRARY SQLite_EXECUTABLE)

#-----------------------------------------------------------------------
# Set user variables and create imported targets if SQLite is found
if(SQLite_FOUND)
  set(SQLite_INCLUDE_DIRS ${SQLite_INCLUDE_DIR})
  set(SQLite_LIBRARIES ${SQLite_LIBRARY})

  if(NOT TARGET SQLite::SQLite)
    add_library(SQLite::SQLite UNKNOWN IMPORTED)
    set_target_properties(SQLite::SQLite PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES     "${SQLite_INCLUDE_DIRS}"
      IMPORTED_LOCATION                 "${SQLite_LIBRARY}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      )
  endif()

  if(NOT TARGET SQLite::SQLiteExecutable)
    add_executable(SQLite::SQLiteExecutable IMPORTED)
    set_target_properties(SQLite::SQLiteExecutable PROPERTIES
      IMPORTED_LOCATION "${SQLite_EXECUTABLE}"
      )
  endif()
endif()

