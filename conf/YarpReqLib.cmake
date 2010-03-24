# Copyright: (C) 2009 RobotCub Consortium
# Authors: Paul Fitzpatrick, Giorgio Metta, Lorenzo Natale, Alessandro Scalzo
# CopyPolicy: Released under the terms of the GNU GPL v2.0.


#########################################################################
# Unsorted material

SET(YARP_ADMIN "$ENV{YARP_ADMIN}")

IF (YARP_ADMIN)
  # be very serious about warnings if in admin mode
  ADD_DEFINITIONS(-Werror -Wfatal-errors)
ENDIF (YARP_ADMIN)

SET(YARP_DEFINES_ACCUM "-DYARP_PRESENT")
ADD_DEFINITIONS(-DYARP_PRESENT)
SET(YARP_DEFINES_ACCUM ${YARP_DEFINES_ACCUM} "-D_REENTRANT")
ADD_DEFINITIONS(-D_REENTRANT)

# on windows, we have to tell ace how it was compiled
IF (WIN32 AND NOT CYGWIN)
  SET(YARP_DEFINES_ACCUM ${YARP_DEFINES_ACCUM} -DWIN32 -D_WINDOWS)
  ADD_DEFINITIONS(-DWIN32 -D_WINDOWS)
ELSE (WIN32 AND NOT CYGWIN)
  ADD_DEFINITIONS(-Wall)
ENDIF (WIN32 AND NOT CYGWIN)

## check if we are on cygwin
IF(WIN32 AND CYGWIN)
  SET(YARP_DEFINES_ACCUM ${YARP_DEFINES_ACCUM} -DCYGWIN)
  ADD_DEFINITIONS(-DCYGWIN)
ENDIF(WIN32 AND CYGWIN)

## check if we are using the MINGW compiler
IF(MINGW)
  SET(YARP_DEFINES_ACCUM ${YARP_DEFINES_ACCUM} -D__MINGW__ -D__MINGW32__ "-mms-bitfields" "-mthreads" "-Wpointer-arith" "-pipe")
  ADD_DEFINITIONS(-D__MINGW__ -D__MINGW32__ "-mms-bitfields" "-mthreads" "-Wpointer-arith" "-pipe")
  # "-fno-exceptions" can be useful too... unless you need exceptions :-)
  IF (MSYS)
    SET(YARP_DEFINES_ACCUM ${YARP_DEFINES_ACCUM} -D__ACE_INLINE__ -DACE_HAS_ACE_TOKEN -DACE_HAS_ACE_SVCCONF -DACE_BUILD_DLL)
    ADD_DEFINITIONS(-D__ACE_INLINE__ -DACE_HAS_ACE_TOKEN -DACE_HAS_ACE_SVCCONF -DACE_BUILD_DLL)
  ELSE (MSYS)
    SET(YARP_DEFINES_ACCUM ${YARP_DEFINES_ACCUM} "-fvisibility=hidden" "-fvisibility-inlines-hidden" "-Wno-attributes")
    ADD_DEFINITIONS("-fvisibility=hidden" "-fvisibility-inlines-hidden" "-Wno-attributes")
  ENDIF (MSYS)
ENDIF(MINGW)

# check endianness
IF(EXISTS "${CMAKE_ROOT}/Modules/TestBigEndian.cmake")
    INCLUDE(TestBigEndian)
    TEST_BIG_ENDIAN(IS_BIG_ENDIAN)
    IF(${IS_BIG_ENDIAN})
        # this flag has been moved to generated file yarp/conf/system.h
	SET(YARP_BIG_ENDIAN 1)
    ELSE(${IS_BIG_ENDIAN})
        # this flag has been moved to generated file yarp/conf/system.h
	SET(YARP_LITTLE_ENDIAN 1)
    ENDIF(${IS_BIG_ENDIAN})
ENDIF(EXISTS "${CMAKE_ROOT}/Modules/TestBigEndian.cmake")


# get an int32 type
IF(EXISTS "${CMAKE_ROOT}/Modules/CheckTypeSize.cmake")
    INCLUDE(CheckTypeSize)

    SET(YARP_INT16)
    SET(YARP_INT32)
    SET(YARP_FLOAT64)

    CHECK_TYPE_SIZE("int" SIZEOF_INT)
    CHECK_TYPE_SIZE("short" SIZEOF_SHORT)
    IF(SIZEOF_INT EQUAL 4)
        SET(YARP_INT32 "int")
    ELSE(SIZEOF_INT EQUAL 4)
        IF(SIZEOF_SHORT EQUAL 4)
            SET(YARP_INT32 "short")
        ELSE(SIZEOF_SHORT EQUAL 4)
            CHECK_TYPE_SIZE("long" SIZEOF_LONG)
            IF(SIZEOF_LONG EQUAL 4)
                SET(YARP_INT32 "long")
            ENDIF(SIZEOF_LONG EQUAL 4)
        ENDIF(SIZEOF_SHORT EQUAL 4)
    ENDIF(SIZEOF_INT EQUAL 4)

    IF(SIZEOF_SHORT EQUAL 2)
        SET(YARP_INT16 "short")
    ELSE(SIZEOF_SHORT EQUAL 2)
        # well, we are in trouble - there's no other native type to get 16 bits
	MESSAGE(STATUS "Warning: cannot find a 16 bit type on your system")
	MESSAGE(STATUS "Continuing...")
    ENDIF(SIZEOF_SHORT EQUAL 2)

    CHECK_TYPE_SIZE("double" SIZEOF_DOUBLE)
    IF(SIZEOF_DOUBLE EQUAL 8)
        SET(YARP_FLOAT64 "double")
    ELSE(SIZEOF_DOUBLE EQUAL 8)
        IF(SIZEOF_FLOAT EQUAL 8)
            SET(YARP_FLOAT64 "float")
        ENDIF(SIZEOF_FLOAT EQUAL 8)
    ENDIF(SIZEOF_DOUBLE EQUAL 8)

ENDIF(EXISTS "${CMAKE_ROOT}/Modules/CheckTypeSize.cmake")

FIND_PACKAGE(Ace REQUIRED)

IF (CREATE_GUIS)
  FIND_PACKAGE(GtkPlus)
  IF (NOT GtkPlus_FOUND)
	MESSAGE(STATUS " gtk+ not found, won't compile dependent tools")
  ENDIF (NOT GtkPlus_FOUND)

  FIND_PACKAGE(Gthread)
  IF (NOT Gthread_FOUND)
	MESSAGE(STATUS " gthread not found, won't compile dependent tools")
  ENDIF(NOT Gthread_FOUND)
ENDIF (CREATE_GUIS)

SET(YARP_HAS_MATH_LIB  FALSE)

IF (CREATE_LIB_MATH)
FIND_PACKAGE(GSL REQUIRED)
IF (NOT GSL_FOUND)
	MESSAGE(STATUS "GSL not found, won't compile libYARP_math")
ELSE (NOT GSL_FOUND)
	SET(YARP_HAS_MATH_LIB TRUE)
ENDIF (NOT GSL_FOUND)
ENDIF(CREATE_LIB_MATH)

IF (ACE_DEBUG_FOUND)
 LINK_LIBRARIES(optimized ${ACE_LIBRARY} debug ${ACE_DEBUG_LIBRARY})
 SET(ACE_LIB optimized ${ACE_LIBRARY} debug ${ACE_DEBUG_LIBRARY} CACHE INTERNAL "libraries")
ELSE (ACE_DEBUG_FOUND)
 LINK_LIBRARIES(${ACE_LIBRARY})
 SET(ACE_LIB ${ACE_LIBRARY} CACHE INTERNAL "libraries")
ENDIF (ACE_DEBUG_FOUND)

INCLUDE_DIRECTORIES(${ACE_INCLUDE_DIR})
INCLUDE_DIRECTORIES(${ACE_INCLUDE_CONFIG_DIR})

IF (${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} GREATER 2.5)
  IF(EXISTS "${CMAKE_ROOT}/Modules/CheckTypeSize.cmake")
    INCLUDE(YarpCheckTypeSize) # regular script does not do C++ types
    SET(CMAKE_EXTRA_INCLUDE_FILES ace/config.h ace/String_Base_Const.h)
    SET(CMAKE_REQUIRED_INCLUDES ${ACE_INCLUDE_DIR} ${ACE_INCLUDE_CONFIG_DIR})
    YARP_CHECK_TYPE_SIZE(ACE_String_Base_Const::size_type SIZE_TYPE)
    SET(CMAKE_EXTRA_INCLUDE_FILES) 
    SET(CMAKE_REQUIRED_INCLUDES)
    SET(YARP_USE_ACE_STRING_BASE_CONST_SIZE_TYPE ${HAVE_SIZE_TYPE})
  ENDIF(EXISTS "${CMAKE_ROOT}/Modules/CheckTypeSize.cmake")
ENDIF (${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} GREATER 2.5)

# give a readout of defines
SET(YARP_DEFINES ${YARP_DEFINES_ACCUM} CACHE STRING "Definitions needed when compiling with YARP")
MARK_AS_ADVANCED(YARP_DEFINES)




