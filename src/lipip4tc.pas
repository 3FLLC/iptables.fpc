{
Free Pascal binding for libip4tc

Copyright (c) 2011 Ido Kanner (idokan at@at gmail dot.dot com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


Documentation arrived from the following web-site:
  http://opalsoft.net/qos/libiptc/qfunction.html
  http://opalsoft.net/qos/libiptc/mfunction.html

IP_TABLES - symbole is to use the header instead of inline code ...
X_TABLES  - symboles for some netfilter headers ...
}

unit lipip4tc;

{$mode fpc}{$packrecords c}

interface

uses
  ctypes
  {$IFDEF IP_TABLES}
    , ip_tables
  {$ELSE}
    , Sockets
  {$ENDIF}
  {$IFDEF X_TABLES}
    , x_tables
  {$ENDIF}
  ;

const
  IPTC_LIBRARY = 'libip4tc';

type
  piptc_handle = ^iptc_handle;
  iptc_handle  = record end;
  tiptc_handle = iptc_handle;

  ipt_chainlabel  = array[0..31] of char;
  tipt_chainlabel = ipt_chainlabel;

{$IFNDEF X_TABLES}
type
  xt_counters = record
    // Packet and byte counters
    pcnt, bcnt : cuint64;
  end;
{$ENDIF}

{$IFNDEF IP_TABLES}
const
  IFNAMSIZ = 16;

type
  pipt_ip = ^ipt_ip;
  ipt_ip  = record
    // Source and Destition IP addr
    src,   dst    : in_addr;
    // Mask for src and dest IP addr
    smask, dmask  : in_addr;
    iniface,
    outiface      : array[0..IFNAMSIZ-1] of Char;
    iniface_mask,
    outiface_mask : array[0..IFNAMSIZ-1] of Char;
	  // Protocol, 0 = ANY
    proto         : cuint16;
	  // Flags word
    flags         : cuint8;
    // Inverse flags
    invflags      : cuint8;
  end;
  tipt_ip = ipt_ip;

  pipt_counters = ^ipt_counters;
  ipt_counters  = xt_counters;
  tipt_counters = ipt_counters;

{ This structure defines each of the firewall rules.  Consists of 3
  parts which are 1) general IP header stuff 2) match specific
  stuff 3) the target to perform if the rule matches }

  pipt_entry = ^ipt_entry;
  ipt_entry  = record
    ip            : ipt_ip;
    // Mark with fields that we care about.
    nfcache       : cuint;
    // Size of ipt_entry + matches
    target_offset : cuint16;
    // Size of ipt_entry + matches + target
    next_offset   : cuint16;
    // Back pointer
    comefrom      : cuint;
    // Packet and byte counters.
    counters      : xt_counters;
    // The matches (if any), then the target.
    elems         : array[0..0] of Char;
  end;
  tipt_entry = ipt_entry;

{$ENDIF}

const
  IPTC_LABEL_ACCEPT = 'ACCEPT';
  IPTC_LABEL_DROP   = 'DROP';
  IPTC_LABEL_QUEUE  = 'QUEUE';
  IPTC_LABEL_RETURN = 'RETURN';

{
* Usage:
   Check if a chain exists.

* Description:
   This function checks to see if the chain described in the parameter chain exists in the table.

* Parameters:
   - chain is a char pointer containing the name of the chain we want to check to.
   - handle is a pointer to a structure of type iptc_handle_t that was obtained by a previous call to iptc_init.

* Returns:
   - integer value 1 (true) if the chain exists;
   - integer value 0 (false) if the chain does not exist.
}
function iptc_is_chain(chain : PChar; handle : piptc_handle) : cint;
 cdecl; external IPTC_LIBRARY;

{
* Usage:
   Takes a snapshot of the rules.

* Description:
   This function must be called as initiator before any other function can be called.

* Parameters:
   - tablename is the name of the table we need to query and/or modify; this could be filter, mangle, nat, etc.

* Returns:
   Pointer to a structure of type iptc_handle_t that must be used as main parameter for the rest of functions we will call from libiptc.
   iptc_init returns the pointer to the structure or NULL if it fails.
   If this happens you can invoke iptc_strerror to get information about the error.
}
function iptc_init(tablename : PChar) : piptc_handle;
 cdecl; external IPTC_LIBRARY;

{
* Usage:
   Free snapshot that was taken by iptc_init

* Description:
   This procedure must be called to free a snapshot that was initialized by iptc_init, when the usage is completed.

* Parameters:
   - h is the pointer for the given snapshot.
}
procedure iptc_free(h : piptc_handle);
 cdecl; external IPTC_LIBRARY;

{
* Usage:
   Iterator functions to run through the chains.

* Description:
   This function returns the first chain name in the table.

* Parameters:
   - Pointer to a structure of type iptc_handle that was obtained by a previous call to iptc_init.

* Returns:
   Char pointer to the name of the chain.
}
function iptc_first_chain(handle : piptc_handle) : PChar;
 cdecl; external IPTC_LIBRARY;

{
* Usage:
   Iterator functions to run through the chains.

* Description:
   This function returns the next chain name in the table; NULL means no more chains.

* Parameters:
   - Pointer to a structure of type iptc_handle_t that was obtained by a previous call to iptc_init.

* Returns:
   Char pointer to the name of the chain.
}
function iptc_next_chain(handle : piptc_handle) : PChar;
 cdecl; external IPTC_LIBRARY;

{
* Usage:
   Get first rule in the given chain.

* Description:
   This function returns a pointer to the first rule in the given chain name; NULL for an empty chain.

* Parameters:
   - chain is a char pointer containing the name of the chain we want to get the rules to.
   - handle is a pointer to a structure of type iptc_handle_t that was obtained by a previous call to iptc_init.

* Returns:
   Returns a pointer to an ipt_entry structure containing information about the first rule of the chain.
}
function iptc_first_rule(chain : PChar; handle : piptc_handle) : pipt_entry;
 cdecl; external IPTC_LIBRARY;

{
* Usage:
   Get the next rule in the given chain.

* Description:
   This function returns a pointer to the next rule in the given chain name; NULL means the end of the chain.

* Parameters:
   - prev is a pointer to a structure of type ipt_entry that must be obtained first by a previous call to the function iptc_first_rule.
     In order to get the second and subsequent rules you have to pass a pointer to the structure containing the information about the previous
     rule of the chain.
   - handle is a pointer to a structure of type iptc_handle_t that was obtained by a previous call to iptc_init.

* Returns:
   Returns a pointer to an ipt_entry structure containing information about the next rule of the chain.
}
function iptc_next_rule (prev : pipt_entry; handle : piptc_handle) : pipt_entry;
 cdecl; external IPTC_LIBRARY;

{
* Usage:
   Get a pointer to the target name of this entry.

* Description:
   This function gets the target of the given rule. If it is an extended target, the name of that target is returned.
   If it is a jump to another chain, the name of that chain is returned. If it is a verdict (eg. DROP), that name is returned.
   If it has no target (an accounting-style rule), then the empty string is returned.
   Note that this function should be used instead of using the value of the verdict field of the ipt_entry structure directly,
   as it offers the above further interpretations of the standard verdict.

* Parameters:
   - e is a pointer to a structure of type ipt_entry that must be obtained first by a previous call to the function iptc_first_rule
     or the function iptc_next_rule.
   - handle is a pointer to a structure of type iptc_handle_t that was obtained by a previous call to iptc_init.

* Returns:
   Returns a char pointer to the target name. See Description above for more information.
}
function iptc_get_target(e : pipt_entry; handle : piptc_handle) : PChar;
 cdecl; external IPTC_LIBRARY;

{
* Usage:
   Is this a built-in chain?

* Description:
    This function is used to check if a given chain name is a built-in chain or not.

* Parameters:
   - chain is a char pointer containing the name of the chain we want to check to.
   - handle is a pointer to a structure of type iptc_handle_t that was obtained by a previous call to iptc_init.

* Returns:
   - Returns integer value 1 (true) if the given chain name is the name of a builtin chain;
   - returns integer value 0 (false) is not.
}
function iptc_builtin(chain : PChar; handle : piptc_handle) : cint;
 cdecl; external IPTC_LIBRARY;

{
* Usage:
   Get the policy of a given built-in chain.

* Description:
   This function gets the policy of a built-in chain, and fills in the counters argument with the hit statistics on that policy.

* Parameters:
   - chain is the built-in chain you want to get the policy to.
   - counter is a pointer to an ipt_counters structure to be filled by the function
   - handle is a pointer to a structure of type iptc_handle_t structure identifying the table we are working to that was obtained
     by a previous call to iptc_init.

* Returns:
   Returns a char pointer to the policy name.
}
function iptc_get_policy(chain   : PChar;
                         counter : pipt_counters;
                         handle : piptc_handle)   : PChar;
 cdecl; external IPTC_LIBRARY;

////////////////////////////////////////////////////////////////////////////////

{
* Usage:
   Insert a new rule in a chain.

* Description:
   This function insert a rule defined in structure type ipt_entry in chain chain into position defined by integer value rulenum.
   Rule numbers start at 1 for the first rule.

* Parameters:
   - chain is a char pointer to the name of the chain to be modified;
   - e is a pointer to a structure of type ipt_entry that contains information about the rule to be inserted.
     The programmer must fill the fields of this structure with values required to define his or her rule before
     passing the pointer as parameter to the function.
   - rulenum is an integer value defined the position in the chain of rules where the new rule will be inserted.
     Rule numbers start at 1 for the first rule.
   - handle is a pointer to a structure of type iptc_handle_t that was obtained by a previous call to iptc_init.

* Returns:
   - Returns integer value 1 (true) if successful;
   - returns integer value 0 (false) if fails. In this case errno is set to the error number generated.

   Use iptc_strerror to get a meaningful information about the problem.
   If errno = 0, it means there was a version error (ie. upgrade libiptc).
}
function iptc_insert_entry(chain   : ipt_chainlabel;
                           e       : pipt_entry;
                           rulenum : cuint;
                           handle  : piptc_handle)    : cint;
 cdecl; external IPTC_LIBRARY;

{
* Usage:
   Replace an old rule in a chain with a new one.

* Description:
   This function replace the entry rule in chain chain positioned at rulenum with the rule defined in structure type ipt_entry.
   Rule numbers start at 1 for the first rule.

* Parameters:
   - chain is a char pointer to the name of the chain to be modified;
   - e is a pointer to a structure of type ipt_entry that contains information about the rule to be inserted.
     The programmer must fill the fields of this structure with values required to define his or her rule before
     passing the pointer as parameter to the function.
   - rulenum is an integer value defined the position in the chain of rules where the old rule will be replaced by the new one.
     Rule numbers start at 1 for the first rule.
   - handle is a pointer to a structure of type iptc_handle_t that was obtained by a previous call to iptc_init.

* Returns:
   - Returns integer value 1 (true) if successful;
   - returns integer value 0 (false) if fails. In this case errno is set to the error number generated.

   Use iptc_strerror to get a meaningful information about the problem.
   If errno = 0, it means there was a version error (ie. upgrade libiptc).
}
function iptc_replace_entry(chain   : ipt_chainlabel;
                            e       : pipt_entry;
                            rulenum : cuint;
                            handle  : piptc_handle)  : cint;
 cdecl; external IPTC_LIBRARY;

{
* Usage:
   Append a new rule in a chain.

* Description:
   This function append a rule defined in structure type ipt_entry in chain chain (equivalent to insert with rulenum = length of chain).

* Parameters:
   - chain is a char pointer to the name of the chain to be modified;
   - e is a pointer to a structure of type ipt_entry that contains information about the rule to be appended.
     The programmer must fill the fields of this structure with values required to define his or her rule before
     passing the pointer as parameter to the function.
   - handle is a pointer to a structure of type iptc_handle_t that was obtained by a previous call to iptc_init.

* Returns:
   - Returns integer value 1 (true) if successful;
   - returns integer value 0 (false) if fails. In this case errno is set to the error number generated.

   Use iptc_strerror to get a meaningful information about the problem.
   If errno = 0, it means there was a version error (ie. upgrade libiptc).
}
function iptc_append_entry(chain  : ipt_chainlabel;
                           e      : pipt_entry;
                           handle : piptc_handle)   : cint;
 cdecl; external IPTC_LIBRARY;

{
* Usage:
   Check whether a matching rule exists

* Description:
   This function check whether a matching rule based on pointer to ipt_entry exists in the chain.

* Parameters:
   - chain is a char pointer to the name of the chain to be compared to;
   - origfw is a pointer for ipt_entry
   - matchmask is a char pointer
   - handle is a pointer to a structure of type iptc_handle_t that was obtained by a previous call to iptc_init.

* Returns:
   - Returns integer value
}
function iptc_check_entry(chain     : ipt_chainlabel;
                          origfw    : pipt_entry;
                          matchmask : PChar;
                          handle    : piptc_handle)   : cint;
 cdecl; external IPTC_LIBRARY;

{
* Usage:
   Delete the first rule in `chain' which matches `e', subject to matchmask (array of length == origfw)

* Description:
   Delete the first rule in `chain' which matches `e', subject to matchmask (array of length == origfw)

* Parameters:
   - chain is a char pointer to the name of the chain to be compared to;
   - origfw is a pointer for ipt_entry
   - matchmask is a char pointer
   - handle is a pointer to a structure of type iptc_handle_t that was obtained by a previous call to iptc_init.

* Returns:
   - Returns integer value
}
function iptc_delete_entry(chain     : ipt_chainlabel;
                           matchmask : PChar;
                           handle    : piptc_handle)    : cint;
 cdecl; external IPTC_LIBRARY;

{
* Usage:
   Delete a rule in a chain.

* Description:
   This function delete the entry rule in chain chain positioned at rulenum. Rule numbers start at 1 for the first rule.

* Parameters:
   - chain is a char pointer to the name of the chain to be modified;
   - rulenum is an integer value defined the position in the chain of rules where the rule will be deleted.
   - handle is a pointer to a structure of type iptc_handle_t that was obtained by a previous call to iptc_init.

* Returns:
   - Returns integer value 1 (true) if successful;
   - returns integer value 0 (false) if fails. In this case errno is set to the error number generated.

   Use iptc_strerror to get a meaningful information about the problem.
   If errno = 0, it means there was a version error (ie. upgrade libiptc).
}
function iptc_delete_num_entry(chain   : ipt_chainlabel;
                               rulenum : cuint;
                               handle  : piptc_handle)   : cint;
 cdecl; external IPTC_LIBRARY;

{
/* Check the packet `e' on chain `chain'.  Returns the verdict, or
   NULL and sets errno. */
const char *iptc_check_packet(const ipt_chainlabel chain,
			      struct ipt_entry *entry,
			      struct iptc_handle *handle);

/* Flushes the entries in the given chain (ie. empties chain). */
int iptc_flush_entries(const ipt_chainlabel chain,
		       struct iptc_handle *handle);

/* Zeroes the counters in a chain. */
int iptc_zero_entries(const ipt_chainlabel chain,
		      struct iptc_handle *handle);

/* Creates a new chain. */
int iptc_create_chain(const ipt_chainlabel chain,
		      struct iptc_handle *handle);

/* Deletes a chain. */
int iptc_delete_chain(const ipt_chainlabel chain,
		      struct iptc_handle *handle);

/* Renames a chain. */
int iptc_rename_chain(const ipt_chainlabel oldname,
		      const ipt_chainlabel newname,
		      struct iptc_handle *handle);

/* Sets the policy on a built-in chain. */
int iptc_set_policy(const ipt_chainlabel chain,
		    const ipt_chainlabel policy,
		    struct ipt_counters *counters,
		    struct iptc_handle *handle);

/* Get the number of references to this chain */
int iptc_get_references(unsigned int *ref,
			const ipt_chainlabel chain,
			struct iptc_handle *handle);

/* read packet and byte counters for a specific rule */
struct ipt_counters *iptc_read_counter(const ipt_chainlabel chain,
				       unsigned int rulenum,
				       struct iptc_handle *handle);

/* zero packet and byte counters for a specific rule */
int iptc_zero_counter(const ipt_chainlabel chain,
		      unsigned int rulenum,
		      struct iptc_handle *handle);

/* set packet and byte counters for a specific rule */
int iptc_set_counter(const ipt_chainlabel chain,
		     unsigned int rulenum,
		     struct ipt_counters *counters,
		     struct iptc_handle *handle);

/* Makes the actual changes. */
int iptc_commit(struct iptc_handle *handle);

/* Get raw socket. */
int iptc_get_raw_socket(void);

/* Translates errno numbers into more human-readable form than strerror. */
const char *iptc_strerror(int err);

extern void dump_entries(struct iptc_handle *const);
}

implementation

end.

