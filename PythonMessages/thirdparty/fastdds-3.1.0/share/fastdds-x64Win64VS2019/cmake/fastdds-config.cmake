# Copyright 2016 Proyectos y Sistemas de Mantenimiento SL (eProsima).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set(fastdds_VERSION 3.1.0)


####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was Config.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################

if(0)
    set_and_check(fastdds_BIN_DIR "${PACKAGE_PREFIX_DIR}/bin")
endif()
set_and_check(fastdds_INCLUDE_DIR "${PACKAGE_PREFIX_DIR}/include")
set_and_check(fastdds_LIB_DIR "${PACKAGE_PREFIX_DIR}/lib")

set(foonathan_memory_DIR "${CMAKE_CURRENT_LIST_DIR}/../../foonathan_memory-x64Win64VS2019/cmake")
find_package(fastcdr REQUIRED)
find_package(foonathan_memory REQUIRED)
find_package(TinyXML2 QUIET)
        function(find_fastdds_deployed_openssl)
            if(OPENSSL_FOUND AND NOT(OPENSSL_VERSION STREQUAL "3.1.4") )
                message(WARNING "OpenSSL already loaded. Version ${OPENSSL_VERSION} differs from version 3.1.4, used in Fast DDS binaries building, ABI issues may arise")
            endif()
            set(OPENSSL_USE_STATIC_LIBS TRUE)
            set(OPENSSL_ROOT_DIR  "${PACKAGE_PREFIX_DIR}/lib/x64Win64VS2019")
            find_package(OpenSSL REQUIRED)
        endfunction()


set(fastdds_known_comps static shared)
set(fastdds_comp_static NO)
set(fastdds_comp_shared NO)
foreach (fastdds_comp IN LISTS ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
    if (fastdds_comp IN_LIST fastdds_known_comps)
        set(fastdds_comp_${fastdds_comp} YES)
    else ()
        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE
            "fastdds does not recognize component `${fastdds_comp}`.")
        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
        return()
    endif ()
endforeach ()

if (fastdds_comp_static AND fastdds_comp_shared)
    set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE
        "fastdds `static` and `shared` components are mutually exclusive.")
    set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
    return()
endif ()

set(fastdds_static_targets "${CMAKE_CURRENT_LIST_DIR}/fastdds-static-targets.cmake")
set(fastdds_shared_targets "${CMAKE_CURRENT_LIST_DIR}/fastdds-shared-targets.cmake")

macro(fastdds_load_targets type)
    if (NOT EXISTS "${fastdds_${type}_targets}")
        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE
            "fastdds `${type}` libraries were requested but not found.")
        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
        return()
    endif ()

    # find related dependency packages like OpenSSL
            if (${type} STREQUAL "static")
            find_fastdds_deployed_openssl()
        endif()
    

    include("${fastdds_${type}_targets}")
endmacro()

if (fastdds_comp_static)
    fastdds_load_targets(static)
elseif (fastdds_comp_shared)
    fastdds_load_targets(shared)
elseif (DEFINED fastdds_SHARED_LIBS AND fastdds_SHARED_LIBS)
    fastdds_load_targets(shared)
elseif (DEFINED fastdds_SHARED_LIBS AND NOT fastdds_SHARED_LIBS)
    fastdds_load_targets(static)
elseif (BUILD_SHARED_LIBS)
    if (EXISTS "${fastdds_shared_targets}")
        fastdds_load_targets(shared)
    else ()
        fastdds_load_targets(static)
    endif ()
else ()
    if (EXISTS "${fastdds_static_targets}")
        fastdds_load_targets(static)
    else ()
        fastdds_load_targets(shared)
    endif ()
endif ()

include(${CMAKE_CURRENT_LIST_DIR}/optionparser-targets.cmake)
