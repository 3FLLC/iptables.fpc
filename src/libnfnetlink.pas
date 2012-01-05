{ Binding of libnetfilter/libnfnetlink.h

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
  {$ERROR This unit is binded to the Linux Operating system.}
{$ENDIF}
unit libnfnetlink;

{$mode fpc}{$PACKRECORDS c}

interface

uses
  ctypes, sockets, netlink_kernel;

{$IF not defined(NETLINK_NETFILTER)}
const
  NETLINK_NETFILTER = 12;
{$ENDIF}

{$IF not defined(SOL_NETLINK)}
const
  SOL_NETLINK = 270;
{$ENDIF}

{$IF not defined(NETLINK_BROADCAST_SEND_ERROR)}
const
  NETLINK_BROADCAST_SEND_ERROR = 4;
{$ENDIF}

{$IF not defined(NETLINK_NO_ENOBUFS)}
const
  NETLINK_NO_ENOBUFS = 5;
{$ENDIF}

//function NLMSG_TAIL(nlh: nlmsghdr): pointer; cdecl; inline;

(*
#define NFNL_HEADER_LEN	(NLMSG_ALIGN(sizeof(struct nlmsghdr))	\
			 +NLMSG_ALIGN(sizeof(struct nfgenmsg)))

#define NFNL_BUFFSIZE		8192

#ifdef __cplusplus
extern "C" {
#endif

struct nfnlhdr {
	struct nlmsghdr nlh;
	struct nfgenmsg nfmsg;
};

struct nfnl_callback {
	int ( *call)(struct nlmsghdr *nlh, struct nfattr *nfa[], void *data);
	void *data;
	u_int16_t attr_count;
};

*)

type
  pnfnl_handle = ^nfnl_handle;
  nfnl_handle  = record end;

  pnfnl_subsys_handle = ^nfnl_subsys_handle;
  nfnl_subsys_handle  = record end;

(*
extern int nfnl_fd(struct nfnl_handle *h);
extern unsigned int nfnl_portid(const struct nfnl_handle *h);

/* get a new library handle */
extern struct nfnl_handle *nfnl_open(void);
extern int nfnl_close(struct nfnl_handle * );

extern struct nfnl_subsys_handle *nfnl_subsys_open(struct nfnl_handle *,
						   u_int8_t, u_int8_t,
						   unsigned int);
extern void nfnl_subsys_close(struct nfnl_subsys_handle * );

/* set and unset sequence tracking */
void nfnl_set_sequence_tracking(struct nfnl_handle *h);
void nfnl_unset_sequence_tracking(struct nfnl_handle *h);

/* set receive buffer size (for nfnl_catch) */
extern void nfnl_set_rcv_buffer_size(struct nfnl_handle *h, unsigned int size);

/* sending of data */
extern int nfnl_send(struct nfnl_handle *, struct nlmsghdr * );
extern int nfnl_sendmsg(const struct nfnl_handle *, const struct msghdr *msg,
			unsigned int flags);
extern int nfnl_sendiov(const struct nfnl_handle *nfnlh,
			const struct iovec *iov, unsigned int num,
			unsigned int flags);
extern void nfnl_fill_hdr(struct nfnl_subsys_handle *, struct nlmsghdr *,
			  unsigned int, u_int8_t, u_int16_t, u_int16_t,
			  u_int16_t);
extern __attribute__((deprecated)) int
nfnl_talk(struct nfnl_handle *, struct nlmsghdr *, pid_t,
          unsigned, struct nlmsghdr *,
          int ( * )(struct sockaddr_nl *, struct nlmsghdr *, void * ), void * );

/* simple challenge/response */
extern __attribute__((deprecated)) int
nfnl_listen(struct nfnl_handle *,
            int ( * )(struct sockaddr_nl *, struct nlmsghdr *, void * ), void * );

/* receiving */
extern ssize_t nfnl_recv(const struct nfnl_handle *h, unsigned char *buf, size_t len);
extern int nfnl_callback_register(struct nfnl_subsys_handle *,
				  u_int8_t type, struct nfnl_callback *cb);
extern int nfnl_callback_unregister(struct nfnl_subsys_handle *, u_int8_t type);
extern int nfnl_handle_packet(struct nfnl_handle *, char *buf, int len);

/* parsing */
extern struct nfattr *nfnl_parse_hdr(const struct nfnl_handle *nfnlh,
				     const struct nlmsghdr *nlh,
				     struct nfgenmsg **genmsg);
extern int nfnl_check_attributes(const struct nfnl_handle *nfnlh,
				 const struct nlmsghdr *nlh,
				 struct nfattr *tb[]);
extern struct nlmsghdr *nfnl_get_msg_first(struct nfnl_handle *h,
					   const unsigned char *buf,
					   size_t len);
extern struct nlmsghdr *nfnl_get_msg_next(struct nfnl_handle *h,
					  const unsigned char *buf,
					  size_t len);

/* callback verdict */
enum {
	NFNL_CB_FAILURE = -1,   /* failure */
	NFNL_CB_STOP = 0,       /* stop the query */
	NFNL_CB_CONTINUE = 1,   /* keep iterating */
};

/* join a certain netlink multicast group */
extern int nfnl_join(const struct nfnl_handle *nfnlh, unsigned int group);

/* process a netlink message */
extern int nfnl_process(struct nfnl_handle *h,
			const unsigned char *buf,
			size_t len);

/* iterator API */

extern struct nfnl_iterator *
nfnl_iterator_create(const struct nfnl_handle *h,
		     const char *buf,
		     size_t len);

extern void nfnl_iterator_destroy(struct nfnl_iterator *it);

extern int nfnl_iterator_process(struct nfnl_handle *h,
				 struct nfnl_iterator *it);

extern int nfnl_iterator_next(const struct nfnl_handle *h,
			      struct nfnl_iterator *it);

/* replacement for nfnl_listen */
extern int nfnl_catch(struct nfnl_handle *h);

/* replacement for nfnl_talk */
extern int nfnl_query(struct nfnl_handle *h, struct nlmsghdr *nlh);

#define nfnl_attr_present(tb, attr)			\
	(tb[attr-1])

#define nfnl_get_data(tb, attr, type)			\
	({	type __ret = 0;				\
	 if (tb[attr-1])				\
	 __ret = *(type * )NFA_DATA(tb[attr-1]);		\
	 __ret;						\
	 })

#define nfnl_get_pointer_to_data(tb, attr, type)	\
	({	type *__ret = NULL;			\
	 if (tb[attr-1])				\
	 __ret = NFA_DATA(tb[attr-1]);			\
	 __ret;						\
	 })

#ifndef NLA_F_NESTED
#define NLA_F_NESTED            (1 << 15)
#endif

/* nfnl attribute handling functions */
extern int nfnl_addattr_l(struct nlmsghdr *, int, int, const void *, int);
extern int nfnl_addattr8(struct nlmsghdr *, int, int, u_int8_t);
extern int nfnl_addattr16(struct nlmsghdr *, int, int, u_int16_t);
extern int nfnl_addattr32(struct nlmsghdr *, int, int, u_int32_t);
extern int nfnl_nfa_addattr_l(struct nfattr *, int, int, const void *, int);
extern int nfnl_nfa_addattr16(struct nfattr *, int, int, u_int16_t);
extern int nfnl_nfa_addattr32(struct nfattr *, int, int, u_int32_t);
extern int nfnl_parse_attr(struct nfattr **, int, struct nfattr *, int);
#define nfnl_parse_nested(tb, max, nfa) \
	nfnl_parse_attr((tb), (max), NFA_DATA((nfa)), NFA_PAYLOAD((nfa)))
#define nfnl_nest(nlh, bufsize, type) 				\
({	struct nfattr *__start = NLMSG_TAIL(nlh);		\
	nfnl_addattr_l(nlh, bufsize, (NLA_F_NESTED | type), NULL, 0); 	\
	__start; })
#define nfnl_nest_end(nlh, tail) 				\
({	(tail)->nfa_len = (void * ) NLMSG_TAIL(nlh) - (void * ) tail; })

extern void nfnl_build_nfa_iovec(struct iovec *iov, struct nfattr *nfa,
				 u_int16_t type, u_int32_t len,
				 unsigned char *val);
extern unsigned int nfnl_rcvbufsiz(const struct nfnl_handle *h,
				   unsigned int size);


extern void nfnl_dump_packet(struct nlmsghdr *, int, char * );

/*
 * index to interface name API
 */

#ifndef IFNAMSIZ
#define IFNAMSIZ 16
#endif

*)

type
  pnlif_handle = ^nlif_handle;
  nlif_handle  = record end;

(*
struct nlif_handle *nlif_open(void);
void nlif_close(struct nlif_handle *orig);
int nlif_fd(struct nlif_handle *nlif_handle);
int nlif_query(struct nlif_handle *nlif_handle);
int nlif_catch(struct nlif_handle *nlif_handle);
int nlif_index2name(struct nlif_handle *nlif_handle,
		    unsigned int if_index,
		    char *name);
int nlif_get_ifflags(const struct nlif_handle *h,
		     unsigned int index,
		     unsigned int *flags);
*)

implementation
uses netlink;

function NLMSG_TAIL(nlh: nlmsghdr): pointer; cdecl;
begin
//  #define NLMSG_TAIL(nlh) \
//	(((void * ) (nlh)) + NLMSG_ALIGN((nlh)->nlmsg_len))
  NLMSG_TAIL := (@nlh + NLMSG_ALIGN(nlh.nlmsg_len));
end;

end.

