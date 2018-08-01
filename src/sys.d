/*
 * Copyright (c) 2016-2018 Philip Pavlick.  All rights reserved.
 *
 * Spelunk! may be modified and distributed, but comes with NO WARRANTY!
 * See license.txt for details.
 */

// In previous iterations this file would detect your architecture and #define
// a bunch of flags so Spelunk! knew what operating system you were using, but
// since we're moving to D I'm pretty sure all we need this file for is
// warning people not to use Apple products

version( Windows )
{
  pragma( msg, "Compiling for Windows" );
}
else version( linux )
{
  pragma( msg, "Compiling for Linux" );
}
else version( FreeBSD )
{
  pragma( msg, "Compiling for FreeBSD" );
}
else
{
  pragma( msg, "WARNING: You are compiling Spelunk! for an operating system that is not currently being actively supported.  While it is highly likely that it will \"just work,\" especially on a Linux distribution or one of the BSDs, it may fail or crash." );
}
