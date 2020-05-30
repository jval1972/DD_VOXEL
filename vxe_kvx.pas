//------------------------------------------------------------------------------
//
//  DD_VOXEL: DelphiDoom Voxel Editor
//  Copyright (C) 2013-2017 by Jim Valavanis
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, inc., 59 Temple Place - Suite 330, Boston, MA
//  02111-1307, USA.
//
// DESCRIPTION:
//  KVX Voxel Format
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  Site  : https://sourceforge.net/projects/delphidoom-voxel-editor/
//          https://sourceforge.net/projects/delphidoom/files/DDVoxels/
//------------------------------------------------------------------------------

unit vxe_kvx;

interface


const
  MAXKVXSIZE = 256;

type
  kvxbuffer_t = array[0..MAXKVXSIZE - 1, 0..MAXKVXSIZE - 1, 0..MAXKVXSIZE - 1] of word;
  kvxbuffer_p = ^kvxbuffer_t;

type
  kvxslab_t = record
	  ztop: byte;		// starting z coordinate of top of slab
	  zleng: byte;  // # of bytes in the color array - slab height
	  backfacecull: byte;	// low 6 bits tell which of 6 faces are exposed 
	  col: array[0..255] of byte;// color data from top to bottom
  end;
  kvxslab_p = ^kvxslab_t;

  TSmallintArray = packed array[0..$7FFF] of Smallint;
  PSmallintArray = ^TSmallintArray;

  TSmallIntPArray = packed array[0..$7FFF] of PSmallIntArray;
  PSmallIntPArray = ^TSmallIntPArray;


implementation

end.
 