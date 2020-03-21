/*
 * Copyright (c) 2015-2020 Philip Pavlick.  See '3rdparty.txt' for other
 * licenses.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  * Neither the name of the SwashRL project nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

// This is the configuration file for SwashRL.  It defines flags which affect
// how your copy of SwashRL will compile.

// SECTION 0: ////////////////////////////////////////////////////////////////
// Instructions for the compiler                                            //
//////////////////////////////////////////////////////////////////////////////

// Setting this to `true` will cause the program to output the current git
// commit number when asked for the version number.  This will not affect
// version numbers which are output to save files for compatibility purposes.
// If you are not compiling from a git repository, you'll have to set this to
// `false` in order to compile.
enum INCLUDE_COMMIT = true;

// SECTION 1: ////////////////////////////////////////////////////////////////
// Display configuration                                                    //
//////////////////////////////////////////////////////////////////////////////

// What character to use for the player.  `'@'` is recommended.
enum SMILEY = '@';

// Whether to use reversed graphics to make walls look more solid and
// connected (this makes the game much more pleasing to the eye on a number
// of terminals I tested with it)
enum REVERSED_WALLS = true;

// Color settings ////////////////////////////////////////////////////////////

// Enables color.  This setting will also enable the FOLIAGE and BLOOD
// settings, defined below, if they are set to `true`.
enum COLOR = true;

// Enables foliage.  Foliage grows randomly in dungeons and has no practical
// effect on gameplay other than turning tiles green.
enum FOLIAGE = true;

// Enables blood.  Blood splatter will appear on map tiles when a creature is
// hit.  This has no practical effect other than turning map tiles red.
enum BLOOD = true;

// Curses-specific options ///////////////////////////////////////////////////

// Enables special effects like the highlighted player and reversed walls.
// Only works if your curses standard uses these effects (it probably does).
enum TEXT_EFFECTS = true;

// SDL-specific options //////////////////////////////////////////////////////

version( sdl )
{

import fonts.d;

// Options specific to builds designed for dyslexic users. (experimental)
version( dyslexia )
{

// A path to a font file to use for the map.  To use a different font, delete
// this line and uncomment one of the alternatives, or write in the path to
// a font which you would prefer.
enum FONT = TileSet.dyslexic;

// A path to a font file to use for the message buffer, status bar, and other
// messages.  By default, a bolder font is used because this has been
// determined to be more readable.
enum MESSAGE_FONT = TileSet.dyslexic;

} // version( dyslexia )

else
{

enum FONT = TileSet.default;

// An alternative, bolder font suggested for users who find the default
// font difficult to read.
//enum FONT = "assets/fonts/DejaVuSansMono-Bold.ttf";

enum MESSAGE_FONT = TileSet.bold;

} // else from version( dyslexia )

} // version( sdl )

// Whether to highlight the player in the game display, as would normally
// happen in a curses terminal when the cursor hovers over the player's
// location.
enum HILITE_PLAYER = true;

// SECTION 2: ////////////////////////////////////////////////////////////////
// SwashRL configuration                                                    //
//////////////////////////////////////////////////////////////////////////////

// The number of messages to store in the message buffer
enum MAX_MESSAGE_BUFFER = 20;
