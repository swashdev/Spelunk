/*
 * Copyright (c) 2017 Philip Pavlick.  All rights reserved.
 *
 * Spelunk! may be modified and distributed, but comes with NO WARRANTY!
 * See license.txt for details.
 */

// This is the global file for Spelunk!.  It will public config.h and util.h
// for you and process the data in both of these files to configure how
// Spelunk! will compile.  THIS FILE SHOULD BE INCLUDED AT THE TOP OF EVERY
// FILE.  It will include all of the other files for you.

/* SECTION 0: ****************************************************************
 * Spelunk! version control & configuration                                  *
 *****************************************************************************/

// The version number
// In the current version numbering system, the first number is the release
// number and the second is the three-digit revision number.
enum VERSION = 0.021;

// Include the config file
public import config;

/* SECTION 1: ****************************************************************
 * Compiler configuration                                                    *
 *****************************************************************************/

// Include the sys file to detect operating system
public import sys;

/* SECTION 2: ****************************************************************
 * curses configuration                                                      *
 *****************************************************************************/

/* public import the necessary version of curses */

public import deimos.ncurses.curses;

// TODO:
////Autodetect version of curses (to disambiguate curses.h)
//# if defined( __NCURSES_H )
//#  define USE_NCURSES
//# elif defined( __PDCURSES__ )
//#  define USE_PDCURSES
//# else
//#  warning "Unrecognized curses--Spelunk! supports ncurses and pdcurses."
//# endif

/* SECTION 3: ****************************************************************
 * Spelunk! final setup                                                      *
 *****************************************************************************/

// The size of the map in the display
// Spelunk! will always attempt to have one line open at the top for the
// message buffer and one at the bottom for the status bar.  If MAP_Y is
// smaller than that, this variable takes effect.  MAP_X will always take
// effect.  MAP_y and MAP_x are used for zero-counted for loops.  NUMTILES is
// the number of tiles allowable on a map (1,760 by default)
enum MAP_Y = 22;
enum MAP_X = 80;

enum MAP_y = MAP_Y - 1;
enum MAP_x = MAP_X - 1;
enum NUMTILES = MAP_Y * MAP_X;

// include the utility file
public import util;

/* SECTION 4: ****************************************************************
 * Global inclusion of all header files not yet included                     *
 *****************************************************************************/

// include the rest of Spelunk!'s files in the order appointed in
// notes/include

public import dice;
public import sym;
public import tsyms;
public import tflags;
public import tile;
public import iflags;
public import item;
public import inven;
public import monst;
public import you;
public import map;
public import fov;
public import display;
public import message;
public import keys;
public import moves;
public import move;
public import invent;
