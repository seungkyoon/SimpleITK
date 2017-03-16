
# set_from_env
# ------------
#
# Sets a CMake variable from an environment variable. If the
# environment variable  is not  defined then either a fatal error is
# generated or the CMake variable is not modified.
#
# set_from_env( <variable> <environment variable> [REQUIRED|DEFAULT value] )
function(set_from_env var env_var)
  if(NOT DEFINED ENV{${env_var}})
    if (ARGV2 STREQUAL "REQUIRED")
      message(FATAL_ERROR "Required environment variable \"${env_var}\" not defined.")
    elseif (ARGV2 STREQUAL "DEFAULT")
      set(${var} ${ARGV3} PARENT_SCOPE)
    endif()
  else()
    set(${var} $ENV{${env_var}} PARENT_SCOPE)
  endif()
endfunction()

set(CTEST_SITE "CircleCI")
set(CTEST_UPDATE_VERSION_ONLY 1)
set(CTEST_TEST_ARGS ${CTEST_TEST_ARGS} PARALLEL_LEVEL 2)

# Make environment variables to CMake variables for CTest
set_from_env(CTEST_CMAKE_GENERATOR "CTEST_CMAKE_GENERATOR" DEFAULT "Unix Makefiles" )
set_from_env(CTEST_BINARY_DIRECTORY "CTEST_BINARY_DIRECTORY")
set_from_env(CTEST_DASHBOARD_ROOT  "CTEST_DASHBOARD_ROOT" REQUIRED)
set_from_env(CTEST_SOURCE_DIRECTORY "CTEST_SOURCE_DIRECTORY" REQUIRED)
set_from_env(CTEST_CONFIGURATION_TYPE "CTEST_CONFIGURATION_TYPE" DEFAULT "Release")
set_from_env(CTEST_BUILD_FLAGS "CTEST_BUILD_FLAGS")


# Construct build name based on what is being built
string(SUBSTRING $ENV{CIRCLE_SHA1} 0 7 commit_sha1)
set(CTEST_BUILD_NAME "CircleCI-$ENV{CIRCLE_BRANCH}-${commit_sha1}")

set_from_env(dashboard_git_branch "CIRCLE_BRANCH")
set_from_env(dashboard_model "DASHBOARD_MODEL" DEFAULT "Experimental" )
set(dashboard_loop 0)

list(APPEND CTEST_NOTES_FILES
  "${CTEST_SOURCE_DIRECTORY}/circle.yml"
  )

SET (dashboard_cache "
    CMAKE_CXX_COMPILER_LAUNCHER:STRING=distcc
    CMAKE_C_COMPILER_LAUNCHER:STRING=distcc
    BUILD_DOCUMENTATION:BOOL=OFF
    BUILD_EXAMPLES:BOOL=OFF
    BUILD_SHARED_LIBS:BOOL=ON
    BUILD_TESTING:BOOL=ON

    USE_SYSTEM_LUA:BOOL=ON
    SimpleITK_EXPLICIT_INSTANTIATION:BOOL=OFF

    WRAP_DEFAULT:BOOL=OFF
    WRAP_PYTHON:BOOL=ON
    ITK_REPOSITORY:STRING=https://github.com/InsightSoftwareConsortium/ITK.git

" )


include("${CTEST_SCRIPT_DIRECTORY}/simpleitk_common.cmake")

if(NOT ${configure_return} EQUAL 0 OR
   NOT ${build_return} EQUAL 0 OR
   NOT ${build_errors} EQUAL 0 OR
   NOT ${build_warnings} EQUAL 0 OR
   NOT ${test_return} EQUAL 0)
  message(FATAL_ERROR
    "Build did not complete without warnings, errors, or failures.")
else()
  return(0)
endif()
