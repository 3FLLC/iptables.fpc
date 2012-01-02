{ translation of linux/netlink.h

  Copyright (C) 2012 Ido Kanner idokan at@at gmail dot.dot com

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
unit netlink;

{$mode fpc}{$packrecords c}

interface

uses
  ctypes, Sockets;

const
 NETLINK_ROUTE          = 0;	// Routing/device hook
 NETLINK_UNUSED         = 1;	// Unused number
 NETLINK_USERSOCK       = 2;  // Reserved for user mode socket protocols
 NETLINK_FIREWALL       = 3;	// Firewalling hook
 NETLINK_INET_DIAG      = 4;	// INET socket monitoring
 NETLINK_NFLOG          = 5;	// netfilter/iptables ULOG
 NETLINK_XFRM           = 6;  // ipsec
 NETLINK_SELINUX        = 7;	// SELinux event notifications
 NETLINK_ISCSI          = 8;  // Open-iSCSI
 NETLINK_AUDIT          = 9;  // auditing
 NETLINK_FIB_LOOKUP     = 10;
 NETLINK_CONNECTOR      = 11;
 NETLINK_NETFILTER      = 12; // netfilter subsystem
 NETLINK_IP6_FW         = 13;
 NETLINK_DNRTMSG        = 14; // DECnet routing messages
 NETLINK_KOBJECT_UEVENT = 15; // Kernel messages to userspace
 NETLINK_GENERIC        = 16;
// leave room for NETLINK_DM (DM Events)
 NETLINK_SCSITRANSPORT  = 18; // SCSI Transports
 NETLINK_ECRYPTFS       = 19;
 NETLINK_RDMA           = 20;

 MAX_LINKS              = 32;

type
 {$IF not defined(__kernel_sa_family_t)}
 __kernel_sa_family_t = cushort;
 {$ENDIF}
 psockaddr_nl = ^sockaddr_nl;
 sockaddr_nl  = record
   nl_family : __kernel_sa_family_t; // AF_NETLINK
   nl_pad    : cuint32;              // zero
   nl_pid    : cuint32;              // port ID
   nl_groups : cuint32;              // multicast groups mask
 end;

 pnlmsghdr = ^nlmsghdr;
 nlmsghdr  = record
  nlmsg_len   : cuint32; // Length of message including header
  nlmsg_type  : cuint16; // Message content
  nlmsg_flags : cuint16; // Additional flags
  nlmsg_seq   : cuint32; // Sequence number
  nlmsg_pid   : cuint32; // Sending process port ID
 end;

// Flags values
const
 NLM_F_REQUEST   = 1;  // It is request message.
 NLM_F_MULTI     = 2;  // Multipart message, terminated by NLMSG_DONE
 NLM_F_ACK       = 4;  // Reply with ack, with zero or error code
 NLM_F_ECHO      = 8;  // Echo this request
 NLM_F_DUMP_INTR = 16; // Dump was inconsistent due to sequence change

 // Modifiers to GET request
 NLM_F_ROOT   = $100; // specify tree	root
 NLM_F_MATCH  = $200; // return all matching
 NLM_F_ATOMIC = $400; // atomic GET
 NLM_F_DUMP   = NLM_F_ROOT or NLM_F_MATCH;

 // Modifiers to NEW request
 NLM_F_REPLACE = $100; // Override existing
 NLM_F_EXCL    = $200; // Do not touch, if it exists
 NLM_F_CREATE  = $400; // Create, if it does not exist
 NLM_F_APPEND  = $800; // Add to end of list

(*
   4.4BSD ADD		NLM_F_CREATE|NLM_F_EXCL
   4.4BSD CHANGE	NLM_F_REPLACE

   True CHANGE		NLM_F_CREATE|NLM_F_REPLACE
   Append		NLM_F_CREATE
   Check		NLM_F_EXCL
 *)

(*

#define NLMSG_ALIGNTO	4U
#define NLMSG_ALIGN(len) ( ((len)+NLMSG_ALIGNTO-1) & ~(NLMSG_ALIGNTO-1) )
#define NLMSG_HDRLEN	 ((int) NLMSG_ALIGN(sizeof(struct nlmsghdr)))
#define NLMSG_LENGTH(len) ((len)+NLMSG_ALIGN(NLMSG_HDRLEN))
#define NLMSG_SPACE(len) NLMSG_ALIGN(NLMSG_LENGTH(len))
#define NLMSG_DATA(nlh)  ((void* )(((char* )nlh) + NLMSG_LENGTH(0)))
#define NLMSG_NEXT(nlh,len)	 ((len) -= NLMSG_ALIGN((nlh)->nlmsg_len), \
				  (struct nlmsghdr* )(((char* )(nlh)) + NLMSG_ALIGN((nlh)->nlmsg_len)))
#define NLMSG_OK(nlh,len) ((len) >= (int)sizeof(struct nlmsghdr) && \
			   (nlh)->nlmsg_len >= sizeof(struct nlmsghdr) && \
			   (nlh)->nlmsg_len <= (len))
#define NLMSG_PAYLOAD(nlh,len) ((nlh)->nlmsg_len - NLMSG_SPACE((len)))

#define NLMSG_NOOP		0x1	/* Nothing.		*/
#define NLMSG_ERROR		0x2	/* Error		*/
#define NLMSG_DONE		0x3	/* End of a dump	*/
#define NLMSG_OVERRUN		0x4	/* Data lost		*/

#define NLMSG_MIN_TYPE		0x10	/* < 0x10: reserved control messages */

struct nlmsgerr {
	int		error;
	struct nlmsghdr msg;
};

#define NETLINK_ADD_MEMBERSHIP	1
#define NETLINK_DROP_MEMBERSHIP	2
#define NETLINK_PKTINFO		3
#define NETLINK_BROADCAST_ERROR	4
#define NETLINK_NO_ENOBUFS	5

struct nl_pktinfo {
	__u32	group;
};

#define NET_MAJOR 36		/* Major 36 is reserved for networking 						*/

enum {
	NETLINK_UNCONNECTED = 0,
	NETLINK_CONNECTED,
};

/*
 *  <------- NLA_HDRLEN ------> <-- NLA_ALIGN(payload)-->
 * +---------------------+- - -+- - - - - - - - - -+- - -+
 * |        Header       | Pad |     Payload       | Pad |
 * |   (struct nlattr)   | ing |                   | ing |
 * +---------------------+- - -+- - - - - - - - - -+- - -+
 *  <-------------- nlattr->nla_len -------------->
 */

struct nlattr {
	__u16           nla_len;
	__u16           nla_type;
};

/*
 * nla_type (16 bits)
 * +---+---+-------------------------------+
 * | N | O | Attribute Type                |
 * +---+---+-------------------------------+
 * N := Carries nested attributes
 * O := Payload stored in network byte order
 *
 * Note: The N and O flag are mutually exclusive.
 */
#define NLA_F_NESTED		(1 << 15)
#define NLA_F_NET_BYTEORDER	(1 << 14)
#define NLA_TYPE_MASK		~(NLA_F_NESTED | NLA_F_NET_BYTEORDER)

#define NLA_ALIGNTO		4
#define NLA_ALIGN(len)		(((len) + NLA_ALIGNTO - 1) & ~(NLA_ALIGNTO - 1))
#define NLA_HDRLEN		((int) NLA_ALIGN(sizeof(struct nlattr)))


#endif	/* __LINUX_NETLINK_H */
*)

implementation

end.

