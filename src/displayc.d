/*
 * Copyright (c) 2016-2018 Philip Pavlick.  All rights reserved.
 *
 * Spelunk! may be modified and distributed, but comes with NO WARRANTY!
 * See license.txt for details.
 */

// Defines the interface for functions related to program output for the
// curses interface.  This file should only be imported from ``display.d''

// We import the necessary version of curses (this isn't done from
// ``global.d'' for us because this file is not imported from there)
version( ncurses )
{ import deimos.ncurses.curses;
}

version( pdcurses )
{ import pdcurses;
}

// Also import the config file so we can use a few of the flags from there
import config;

// This class contains functions for the curses display
// These functions should all be cross-compatible between pdcurses and ncurses
// since they don't do anything fancy or complicated.
class CursesDisplay : Display
{

  void setup()
  {
    initscr();
    // Do not echo user input
    noecho();
  }

  void cleanup()
  {
    getch();
    endwin();
  }

  void display( uint y, uint x, symbol s, bool center = false )
  {
    mvaddch( y, x, s.ch );

static if( TEXT_EFFECTS )
{
    mvchgat( y, x, 1, s.color, cast(short)0, cast(void*)null );
}

    if( !center )
    { move( y, x + 1 );
    }
  }

  void display_player( player u )
  {
    display( u.y + Y_OFFSET, u.x, u.sym, true );
  }

  void display_mon( monst m )
  {
    display( m.y + Y_OFFSET, m.x, m.sym );
  }

  void display_map_mons( map to_display )
  {
    size_t d = to_display.m.length;
    monst mn;
    foreach( c; 0 .. d )
    {
      mn = to_display.m[c];

static if( USE_FOV )
{
     if( to_display.v[mn.y][mn.x] )
     { display_mon( mn );
     }
}
else
{
     display_mon( mn );
}

    } /* foreach( c; 0 .. d ) */
  }

  void display_map( map to_display )
  {
    foreach( y; 0 .. MAP_Y )
    {
      foreach( x; 0 .. MAP_X )
      {
        symbol output = to_display.t[y][x].sym;

        if( to_display.i[y][x].sym.ch != '\0' )
        { output = to_display.i[y][x].sym;
        }

static if( USE_FOV )
{
        if( !to_display.v[y][x] )
        { output = SYM_SHADOW;
        }
} /* static if( USE_FOV ) */

        display( y + 1, x, output );
      } /* foreach( x; 0 .. MAP_X ) */
    } /* foreach( y; 0 .. MAP_Y ) */
  }

  void display_map_all( map to_display )
  {
    display_map( to_display );
    display_map_mons( to_display );
  }

  void display_map_and_player( map to_display, player u )
  {
    display_map_all( to_display );
    display_player( u );
  }

  void clear_message_line()
  {
    foreach( y; 0 .. MESSAGE_BUFFER_LINES )
    {
      foreach( x; 0 .. MAP_X )
      { display( y, x, symdata( ' ', A_NORMAL ) );
      }
    }
  }

  void refresh_status_bar( player* u )
  {
    int hp = u.hp;
    int dice = u.attack_roll.dice + u.inventory.items[INVENT_WEAPON].addd;
    int mod = u.attack_roll.modifier + u.inventory.items[INVENT_WEAPON].addm;

    foreach( x; 0 .. MAP_X )
    { mvaddch( 1 + MAP_Y, x, ' ', 0 );
    }
    mvprintw( 1 + MAP_Y, 0, "HP: %d    Attack: %ud %c %u",
              hp, dice, mod >= 0 ? '+' : '-', mod * ((-1) * mod < 0) );
  }

} /* class CursesDisplay */