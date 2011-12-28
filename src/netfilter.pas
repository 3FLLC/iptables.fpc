{ translation of linux/netfilter.h

  Copyright (C) 2011 Ido Kanner idokan at@at gmail dot.dot com

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}

{$IFNDEF LINUX}
   {$ERROR This unit can work only with Linux - It requires iptables that are part of the Linux kernel}
{$ENDIF}
unit netfilter;

{$mode fpc}{$packrecords c}

interface

uses
  ctypes, sockets;

// Responses from hook functions.
const
  NF_DROP        = 0;
  NF_ACCEPT      = 1;
  NF_STOLEN      = 2;
  NF_QUEUE       = 3;
  NF_REPEAT      = 4;
  NF_STOP        = 5;
  NF_MAX_VERDICT = NF_STOP;

(* we overload the higher bits for encoding auxiliary data such as the queue
 * number or errno values. Not nice, but better than additional function
 * arguments. *)
  NF_VERDICT_MASK = $000000ff;

(* extra verdict flags have mask 0x0000ff00 *)
  NF_VERDICT_FLAG_QUEUE_BYPASS = $00008000;

(* queue number (NF_QUEUE) or errno (NF_DROP) *)
  NF_VERDICT_QMASK = $ffff0000;
  NF_VERDICT_QBITS = 16;

procedure NF_QUEUE_NR(var x : cint); inline; cdecl;
procedure NF_DROP_ERR(var x: cint); inline; cdecl;

(* only for userspace compatibility
   Generic cache responses from hook functions.
   <= 0x2000 is used for protocol-flags. *)
const
 NFC_UNKNOWN = $4000;
 NFC_ALTERED = $8000;

 // NF_VERDICT_BITS should be 8 now, but userspace might break if this changes
 NF_VERDICT_BITS = 16;

type
  nf_inet_hooks = cint;

const
 NF_INET_PRE_ROUTING  = 0;
 NF_INET_LOCAL_IN     = 1;
 NF_INET_FORWARD      = 2;
 NF_INET_LOCAL_OUT    = 3;
 NF_INET_POST_ROUTING = 4;
 NF_INET_NUMHOOKS     = 5;

 NFPROTO_UNSPEC       = 0;
 NFPROTO_IPV4         = 2;
 NFPROTO_ARP          = 3;
 NFPROTO_BRIDGE       = 7;
 NFPROTO_IPV6         = 10;
 NFPROTO_DECNET       = 12;
 NFPROTO_NUMPROTO     = 13;

type
  pnf_inet_addr = ^nf_inet_addr;
  nf_inet_addr  = record
    case integer of
     0 : (all : array[0..3] of cuint32);
     1 : (ip  : cuint32);
     2 : (ip6 : array[0..3] of cuint32);
     3 : (in_ : in_addr);
     4 : (in6 : in6_addr);
  end;

implementation

procedure NF_QUEUE_NR(var x : cint); cdecl;
begin
// #define NF_QUEUE_NR(x) ((((x) << 16) & NF_VERDICT_QMASK) | NF_QUEUE)
  x := ((x shl 16) and NF_VERDICT_QMASK) or NF_QUEUE;
end;

procedure NF_DROP_ERR(var x: cint); cdecl;
begin
// #define NF_DROP_ERR(x) (((-x) << 16) | NF_DROP)
  x := (-x shl 16) or NF_DROP;
end;

end.

