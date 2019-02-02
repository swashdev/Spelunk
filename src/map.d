/*
 * Copyright 2016-2019 Philip Pavlick
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License.  You may obtain a copy
 * of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SwashRL is distributed with a special exception to the normal Apache
 * License 2.0.  See LICENSE for details.
 */

import global;

// A `struct' used to store `Room's for the Map generation code
struct Room
{
  uint x1, y1, x2, y2;
}

// Defines a struct ``Map'' which stores Map data, including Map Tiles and
// Monsters and Items on the Map

/++
 + The Map struct
 +
 + This struct defines a Map.
 +
 + It contains a two-layered array of `Tile`s, `t`, which represents Map
 + Tiles; a dynamic array of `Monst`s, `m`, which represents the Monsters on
 + the Map; a two-layered array of `Item`s, `i`, which represents the Items
 + contained on each Tile of the Map.
 +
 + The Map also contains an array of two `ubyte`s, `player_start`, which
 + represents where the player starts out when the Map is loaded.  This is
 + currently only used for opening save files.
 +
 + The Map also contains an array of nine `Room`s, `r`, which is not currently
 + used by any function.
 +/
struct Map
{
  Tile[MAP_X][MAP_Y]   t; // `t'iles
  Monst[]              m; // 'm'onsters
  Item[MAP_X][MAP_Y]   i; // 'i'tems

  Room[9] r;

  bool[MAP_X][MAP_Y] v; // 'v'isibility

  ubyte[2] player_start;

}

/++
 + Adds a Monster to the given Map.
 +
 + This function adds a given `Monst` to the given `Map`'s `m` array.
 +
 + See_Also:
 +   <a href="#remove_mon">remove_mon</a>
 +
 + Params:
 +   mp = A pointer to the Map which mn is to be added to.  mp will be changed
 +        by the function, hence why it needs to be a pointer.
 +   mn = The Monster to be added to mp.
 +/
void add_mon( Map* mp, Monst mn )
{
  size_t mndex = mp.m.length;
  if( mndex < NUMTILES )
  {
    mp.m.length++;
    mp.m[mndex] = mn;
  }
}

/++
 + Removes a Monster from the given Map.
 +
 + This function will remove the Monster given by index from `mp`'s `m` array.
 + The Monster is removed by overwriting it with all of the Monsters to the
 + right of it in the array and then truncating the length of the array.
 +
 + See_Also:
 +   <a href="#add_mon">add_mon</a>
 +
 + Params:
 +   mp    = A pointer to the Map which the Monster at index is to be removed
 +           from.  mp will be changed by the function, hence why it needs to
 +           be a pointer.
 +   index = The index in `mp.m` which is to be removed.
 +/
void remove_mon( Map* mp, uint index )
{
  // To remove a Monster in a Map's mon array, move all Monsters that are
  // past it in the array up, thus overwriting it.
  if( index < mp.m.length )
  {
    foreach( mn; index + 1 .. mp.m.length )
    { mp.m[mn - 1] = mp.m[mn];
    }
    mp.m.length--;
  }
}

/++
 + Carves a vertical corridor in m at the given coordinates
 +
 + This function adds a corridor at the given coordinates to the given Map m.
 +
 + The corridor is generated by replacing all of the Map Tiles inside it
 + with floor Tiles.  Water is not replaced by this function.
 +
 + The generated corridor will start at (x, y1) and end at (x, y2)
 +
 + See_Also:
 +   <a href="#add_corridor_x">add_corridor_x</a>,
 +   <a href="#generate_new_map">generate_new_map</a>
 +
 + Params:
 +   x  = The x coordinate at which the corridor will be generated
 +   y1 = The y coordinate at which the corridor will start
 +   y2 = The y coordinate at which the corridor will end
 +   m  = A pointer to the `Map` which will be modified by the function
 +
 + Returns:
 +   `true` if the corridor was added to m successfully, `false` otherwise
 +/
bool add_corridor_y( uint x, uint y1, uint y2, Map* m )
{
  // Check if the corridor will be within the bounds of the Map.
  if( x < 1 || x > MAP_x )
  { return false;
  }
  if( y1 < 1 || y1 > MAP_y || y2 < 1 || y2 > MAP_y )
  { return false;
  }

  // if y2 < y1, swap the two.
  uint sta, end;
  if( y2 < y1 )
  {
    sta = y2;
    end = y1;
  }
  else
  {
    sta = y1;
    end = y2;
  }

  // Carve all locations along the line [y, index], where `index' is the most
  // recent spot carved.
  foreach( y; sta .. (end + 1) )
  {
    // Do not destroy water by carving
    if( m.t[y][x] != Terrain.water )
    { m.t[y][x] = Terrain.floor;
    }
  }

  return true;
} // bool add_corridor_x( uint, uint, uint, Map* )

/++
 + Carves a horizontal corridor in m at the given coordinates
 +
 + This function adds a corridor at the given coordinates to the given Map m.
 +
 + The corridor is generated by replacing all of the Map Tiles inside it
 + with floor Tiles.  Water is not replaced by this function.
 +
 + The generated corridor will start at (x1, y) and end at (x2, y)
 +
 + See_Also:
 +   <a href="#add_corridor_y">add_corridor_y</a>,
 +   <a href="#generate_new_map">generate_new_map</a>
 +
 + Params:
 +   y  = The y coordinate at which the corridor will be generated
 +   x1 = The x coordinate at which the corridor will start
 +   x2 = The x coordinate at which the corridor will end
 +   m  = A pointer to the `Map` which will be modified by the function
 +
 + Returns:
 +   `true` if the corridor was added to m successfully, `false` otherwise
 +/
bool add_corridor_x( uint y, uint x1, uint x2, Map* m )
{
  // Check if the corridor will be within the bounds of the Map.
  if( y < 1 || y > MAP_y )
  { return false;
  }
  if( x1 < 1 || x1 > MAP_x || x2 < 1 || x2 > MAP_x )
  { return false;
  }

  // if x2 < x1, swap the two.
  uint sta, end;
  if( x2 < x1 )
  {
    sta = x2;
    end = x1;
  }
  else
  {
    sta = x1;
    end = x2;
  }

  // Carve all locations along the line [y, index], where `index' is the most
  // recent spot carved.
  foreach( x; sta .. (end + 1) )
  {
    // Do not destroy water by carving
    if( m.t[y][x] != Terrain.water )
    { m.t[y][x] = Terrain.floor;
    }
  }

  return true;
} // bool add_corridor_x( uint, uint, uint, Map* )

/++
 + Carves a Room into the given Map
 +
 + This function adds a Room to the given Map `m` by replacing all Map Tiles
 + within the square represented by the given coordinates with floor Tiles.
 + Water will not be changed by this function.
 +
 + The Room's northwesternmost point will be located at the coordinates
 + (x1, y1) and its southeasternmost point will be located at the coordinates
 + (x2, y2), not including the wall which surrounds the Room.
 +
 + Params:
 +   y1 = The y coordinate of the generated Room's northwesternmost point
 +   x1 = The x coordinate of the generated Room's northwesternmost point
 +   y2 = The y coordinate of the generated Room's southeasternmost point
 +   x2 = The x coordinate of the generated Room's southeasternmost point
 +   m  = A pointer to the `Map` which is to be modified by this function
 +
 + Returns:
 +   `true` if the Room was added successfully to m, `false` otherwise
 +/
bool add_room( uint y1, uint x1, uint y2, uint x2, Map* m )
{
  // Check if the Room will fit within the bounds of the Map.
  if( x1 > MAP_x || x1 < 1 || x2 > MAP_x || x2 < 1 )
  { return false;
  }
  if( y1 > MAP_y || y1 < 1 || y2 > MAP_y || y2 < 1 )
  { return false;
  }

  // Carve out the Room
  foreach( index_y; y1 .. (y2 + 1) )
  {
    foreach( index_x; x1 .. (x2 + 1) )
    {
      m.t[index_y][index_x] = Terrain.floor;
    }
  }

  return true;
} // bool add_room( uint, uint, uint, uint, Map* )

/++
 + Carves a given `Room` into the given `Map`
 +
 + This function adds the Room r to the Map m.
 +
 + This is essentially a shortcut for the above longform version of this
 + function.
 +
 + Params:
 +   r = The `Room` to be added to m
 +   m = A pointer to the Map which is to be modified by this function
 +
 + Returns:
 +   `true` if r was added successfully to m, `false` otherwise
 +/
bool add_room( Room r, Map* m )
{
  return add_room( r.y1, r.x1, r.y2, r.x2, m );
} // bool add_room( Room, Map* )

static if( FOLIAGE )
{
/++
 + Grows mold in the given Map
 +
 + This function adds mold to m by adding the `SPECIAL_MOLD` flag to a series
 + of randomly chosen `Tile`s in `m.t`.
 +
 + This function will grow anywhere from 0 to 9 patches of mold, each of which
 + will affect a number of Tiles between 1 and 100.  This function does not
 + check to see if it is doubling back on itself, so the actual number of
 + Tiles changed may differ from the number that was set by the random number
 + generator functions.
 +
 + You may have noticed from the previous paragraph that this function might
 + not generate any mold at all; this is intentional.  Not every dungeon level
 + is equally dank.
 +
 + See_Also:
 +   <a href="#generate_new_map">generate_new_map</a>
 +
 + Params:
 +   m = A pointer to the `Map` which is to be modified by this function.
 +/
void grow_mold( Map* m )
{
  import std.random;

  // This is the number of seeds we're going to have for mold growths:
  int num_molds = td10();

  if( num_molds > 0 )
  {
    foreach( c; 1 .. num_molds )
    {
      // This is the maximum number of Tiles this mold growth will affect:
      int mold_len = d100();

      // Choose coordinates where our mold growth will start:
      int x = uniform( 0, MAP_X, Lucky );
      int y = uniform( 0, MAP_Y, Lucky );

      // Now we begin growing mold:
      foreach( d; 1 .. mold_len )
      {
        // Place mold on the current Tile:
        m.t[y][x].hazard |= SPECIAL_MOLD;

        // Now decide a random direction to move in:
        final switch( uniform( 0, 10, Lucky ) )
        {
          // You may notice that values which modify x are slightly more
          // common; this is to encourage the mold to spread out along the
          // wider x axis and fill more of the Map
          case 0: x--; y--; break;
          case 1:
          case 2: x--;      break;
          case 3: x--; y++; break;
          case 4:      y++; break;
          case 5:      y--; break;
          case 6: x++; y--; break;
          case 7:
          case 8: x++;      break;
          case 9: x++; y++; break;
        }

        // Terminate growing mold if we hit the edge of the Map
        if( x >= MAP_X || x < 0 ) break;
        if( y >= MAP_Y || y < 0 ) break;
      } // foreach( d; 1 .. mold_len )
    } // foreach( c; 1 .. num_molds )
  } // if( num_molds > 0 )

  // Also grow mold around pools of water by first searching for water Tiles:
  foreach( y; 0 .. MAP_Y )
  {
    foreach( x; 0 .. MAP_X )
    {
      if( m.t[y][x].hazard & HAZARD_WATER )
      {
        // 1 in 4 chance the Tile will have mold growing near it...
        if( dn(4) == 1 )
        {
          // Grow mold in a random Tile near the water...
          int trux, truy;

          do
          {
            trux = flip() ? x : flip() ? x + 1 : x - 1;
            truy = flip() ? y : flip() ? y + 1 : y - 1;
          } while( trux == x && truy == y );

          // Cancel here if x or y are out of bounds
          if( trux >= MAP_X || trux < 0 ) continue;
          if( truy >= MAP_Y || truy < 0 ) continue;

          m.t[y][x].hazard |= SPECIAL_MOLD;
        }
      }
    } // foreach( x; 0 .. MAP_X )
  } // foreach( y; 0 .. MAP_Y )
} // void grow_mold( Map* )
} // static if( FOLIAGE )

/++
 + Randomly generates a new `Map`
 +
 + This function will generate a new dungeon level.  This is accomplished by
 + splitting the `Map` into nine sectors, placing a `Room` within each sector,
 + and then randomly connecting them with corridors.
 +
 + Currently, the function is written to guarantee that there will always be a
 + path which connects all of the Rooms, but there are no checks to prevent
 + the Rooms from overlapping.
 +
 + If `FOLIAGE` is `true`, this function will also `grow_mold` in the Map
 + before returning it.
 +
 + See_Also:
 +   <a href="#add_corridor_y">add_corridor_y</a>,
 +   <a href="#add_corridor_x">add_corridor_x</a>,
 +   <a href="#add_room">add_room</a>
 +
 + Returns:
 +   A `Map` with Rooms and corridors randomly generated
 +/
Map generate_new_map()
{
  import std.random;

  // We're going to use a classic Roguelike Room generation system:  Split the
  // Map into nine sectors, generate a Room in each one, and then connect them
  // with corridors.

  // These integers will tell us what the Room boundaries for each sector are.
  // Note that some of them overlap; this is intentional.
  uint s1x1 = 1,  s1x2 = 26, s1y1 = 1,  s1y2 = 7;
  uint s2x1 = 26, s2x2 = 52, s2y1 = 1,  s2y2 = 7;
  uint s3x1 = 52, s3x2 = 78, s3y1 = 1,  s3y2 = 7;
  uint s4x1 = 1,  s4x2 = 26, s4y1 = 7,  s4y2 = 13;
  uint s5x1 = 26, s5x2 = 52, s5y1 = 7,  s5y2 = 13;
  uint s6x1 = 52, s6x2 = 78, s6y1 = 7,  s6y2 = 13;
  uint s7x1 = 1,  s7x2 = 26, s7y1 = 13, s7y2 = 20;
  uint s8x1 = 26, s8x2 = 52, s8y1 = 13, s8y2 = 20;
  uint s9x1 = 52, s9x2 = 78, s9y1 = 13, s9y2 = 20;

  // An array that stores generated Rooms:
  Room[9] r;

  // An empty Map:
  Map m = empty_Map();

  foreach( c; 0 .. 9 )
  {
    uint x1, x2, y1, y2;

    final switch( c )
    {
      case 0:
        x1 = s1x1; x2 = s1x2; y1 = s1y1; y2 = s1y2;
        break;
      case 1:
        x1 = s2x1; x2 = s2x2; y1 = s2y1; y2 = s2y2;
        break;
      case 2:
        x1 = s3x1; x2 = s3x2; y1 = s3y1; y2 = s3y2;
        break;
      case 3:
        x1 = s4x1; x2 = s4x2; y1 = s4y1; y2 = s4y2;
        break;
      case 4:
        x1 = s5x1; x2 = s5x2; y1 = s5y1; y2 = s5y2;
        break;
      case 5:
        x1 = s6x1; x2 = s6x2; y1 = s6y1; y2 = s6y2;
        break;
      case 6:
        x1 = s7x1; x2 = s7x2; y1 = s7y1; y2 = s7y2;
        break;
      case 7:
        x1 = s8x1; x2 = s8x2; y1 = s8y1; y2 = s8y2;
        break;
      case 8:
        x1 = s9x1; x2 = s9x2; y1 = s9y1; y2 = s9y2;
        break;
    } // switch( c )

room_gen:

    Room t;
    t.x1 = uniform( x1, x2 - 2, Lucky );
    t.x2 = uniform( t.x1 + 2, x2, Lucky );
    t.y1 = uniform( y1, y2 - 2, Lucky );
    t.y2 = uniform( t.y1 + 2, y2, Lucky );

    // This if statement is just a failsafe.  It shouldn't be necessary, but
    // I like to idiot-proof myself.
    if( !add_room( t, &m ) )
    { goto room_gen;
    }

    r[c] = t;
        
  } // foreach( c; 0 .. 9 )

  // Shuffle the Rooms so that we can generate corridors randomly rather than
  // in a predictable line while still ensuring that all of the Rooms are
  // connected.
  Room[9] rr = r.dup.randomShuffle( Lucky );

  // Randomly get coordinates from each Room and connect them
  foreach( c; 0 .. 8 )
  {

    Room r1 = rr[c];
    Room r2 = rr[c + 1];

    uint x1 = uniform( r1.x1, r1.x2 + 1, Lucky );
    uint x2 = uniform( r2.x1, r2.x2 + 1, Lucky );
    uint y1 = uniform( r1.y1, r1.y2 + 1, Lucky );
    uint y2 = uniform( r2.y1, r2.y2 + 1, Lucky );

    // Randomly decide whether to carve horizontally or vertically first.
    if( flip() )
    {
      add_corridor_x( y1, x1, x2, &m );
      add_corridor_y( x2, y1, y2, &m );
    }
    else
    {
      add_corridor_y( x1, y1, y2, &m );
      add_corridor_x( y2, x1, x2, &m );
    }
  } // foreach( c; 0 .. 7 )

static if( FOLIAGE )
{
  // Plant mold in the Map:
  grow_mold( &m );
}

  // Finally, get random coordinates from a random Room and put the player
  // there:

  uint srindex = uniform( 0, 9, Lucky );

  Room sr = r[ uniform( 0, 9, Lucky ) ];

  ubyte px = cast(ubyte)uniform( sr.x1 + 1, sr.x2, Lucky );
  ubyte py = cast(ubyte)uniform( sr.y1 + 1, sr.y2, Lucky );

  m.player_start = [py, px];

  // Pass the generated Rooms to the Map for record-keeping
  m.r = r;

  return m;
} // Map generate_new_map()

/++
 + Generates an empty `Map`
 +/
Map empty_Map()
{
  Map m;
  foreach( y; 0 .. MAP_Y )
  {
    foreach( x; 0 .. MAP_X )
    {
      m.i[y][x] = No_item;
      m.t[y][x] = Terrain.wall;
    }
  }

  m.player_start = [ 0, 0 ];

  return m;
}

debug
{

/++
 + Generates the test Map
 +/
Map test_map()
{
  Map nu;

  nu.player_start = [ 1, 1 ];

  foreach( y; 0 .. MAP_Y )
  {
    foreach( x; 0 .. MAP_X )
    {
      nu.i[y][x] = No_item;
      if( y == 0 || y == MAP_y || x == 0 || x == MAP_x )
      {
        nu.t[y][x] = Terrain.wall;
      }
      else
      {
        if( (y < 13 && y > 9) && ((x > 19 && x < 24) || (x < 61 && x > 56)) )
        { nu.t[y][x] = Terrain.wall;
        }
        else
        {
          if( (y < 13 && y > 9) && (x > 30 && x < 50) )
          { nu.t[y][x] = Terrain.water;
          }
          else
          { nu.t[y][x] = Terrain.floor;
          }
        } /* else from if( (y < 13 && y > 9) ... */
      } /* else from if( y == 0 || y == MAP_y ... */
    } /* foreach( x; 0 .. MAP_X ) */
  } /* foreach( y; 0 .. MAP_Y ) */

static if( FOLIAGE )
{
  grow_mold( &nu );
}

  // test Monsters

  Monst goobling = new_monst_at( 'g', "goobling", 0, 0, 2, 2, 0, 10, 2, 0, 2,
                                 1000, 60, 20 );
  goobling.sym.color = Color( CLR_DARKGRAY, false );

  add_mon( &nu, goobling );

static if( false ) /* never */
{
  goobling.x = 50;
  add_mon( &nu, goobling );
  goobling.y = 10;
  add_mon( &nu, goobling );
}

  // test Items

  // a test Item "old sword" which grants a +2 bonus to the player's
  // attack roll
  Item old_sword = { sym:symdata( '(', CLR_DEFAULT ),
                     name:"old sword",
                     type:ITEM_WEAPON, equip:EQUIP_NO_ARMOR,
                     addd:0, addm:2 };
  nu.i[10][5] = old_sword;

// I'm too lazy to do all of this crap right now (TODO)
static if( false ) /* never */
{
  Item ring = { .sym = symdata( '=', A_NORMAL ),
                .name = "tungsten ring",
                .type = ITEM_JEWELERY, .equip = EQUIP_JEWELERY_RING,
                .addd = 0, .addm = 0 };
  nu.i[10][2] = ring;
  nu.i[10][1] = ring;
  Item helmet = { .sym = symdata( ']', A_NORMAL ),
                  .name = "hat",
                  .type = ITEM_ARMOR, .equip = EQUIP_HELMET,
                  .addd = 0, .addm = 0 };
  nu.i[10][3] = helmet;
  Item scarf = { .sym = symdata( ']', A_NORMAL ),
                 .name = "fluffy scarf",
                 .type = ITEM_ARMOR, .equip = EQUIP_JEWELERY_NECK,
                 .addd = 0, .addm = 0 };
  nu.i[11][3] = scarf;
  Item tunic = { .sym = symdata( ']', A_NORMAL ),
                 .name = "tunic",
                 .type = ITEM_ARMOR, .equip = EQUIP_CUIRASS,
                 .addd = 0, .addm = 0 };
  nu.i[12][3] = tunic;
  Item gloves = { .sym = symdata( ']', A_NORMAL ),
                  .name = "pair of leather gloves",
                  .type = ITEM_ARMOR, .equip = EQUIP_BRACERS,
                  .addd = 0, .addm = 1 };
  nu.i[13][3] = gloves;
  Item pants = { .sym = symdata( ']', A_NORMAL ),
                 .name = "pair of trousers",
                 .type = ITEM_ARMOR, .equip = EQUIP_GREAVES,
                 .addd = 0, .addm = 0 };
  nu.i[14][3] = pants;
  Item kilt = { .sym = symdata( ']', A_NORMAL ),
                .name = "plaid kilt",
                .type = ITEM_ARMOR, .equip = EQUIP_KILT,
                .addd = 0, .addm = 0 };
  nu.i[15][3] = kilt;
  Item boots = { .sym = symdata( ']', A_NORMAL ),
                 .name = "pair of shoes",
                 .type = ITEM_ARMOR, .equip = EQUIP_FEET,
                 .addd = 0, .addm = 0 };
  nu.i[16][3] = boots;
  Item tailsheath = { .sym = symdata( ']', A_NORMAL ),
                      .name = "leather tailsheath",
                      .type = ITEM_ARMOR, .equip = EQUIP_TAIL,
                      .addd = 0, .addm = 1 };
  nu.i[17][3] = tailsheath;
} /* static if( false ) */
  
  return nu;
}

}
