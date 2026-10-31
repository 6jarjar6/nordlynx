#!/bin/sh
# wg_age.sh -- print the age in seconds of the OLDEST peer's latest
# handshake for a WireGuard interface (default wg0).
#
# Prints nothing on failure: missing interface, no peers, or no output.
# Consumers translate that into a dead decision (fail-closed).
#
# wg reports latest-handshakes differently depending on the
# wireguard-tools version:
#   - older tools: a human-readable duration such as "1 hour ago"
#     (or "2 days ago" or "never");
#   - newer tools (1.0.20260223+): the raw epoch seconds of the last
#     handshake (0 when never).
# Both formats are understood: a 10+-digit token is taken as an epoch
# (age = now - epoch; 0 means never; negative clamped to 0), anything
# else is converted from the human duration to seconds. An epoch is
# safely distinguished from a duration value (a 9-digit duration maxes
# out far below 10^9). We take the oldest peer (the conservative
# choice: one fresh handshake must not mask a stale peer).
#
# Used by BOTH the post-connect watchdog (etc/services.d/wireguard/run)
# and the image HEALTHCHECK -- one parser, one behaviour.

iface=wg0
if [ "${1}" = "--iface" ] && [ -n "${2}" ]; then
  iface="${2}"
fi

# A missing interface makes wg fail; swallow it (nothing printed = dead).
out=$( { wg show "${iface}" latest-handshakes 2>/dev/null || true; } )
[ -n "${out}" ] || exit 0

now=$(date +%s)
age=$(printf '%s\n' "${out}" | awk -v now="${now}" '
    NF == 0 { next }
    {
      tok=$NF
      # Newer tools (1.0.20260223+) print the raw epoch (10 digits),
      # or a bare 0 when never handshaked. Old tools print a human
      # duration ("11 minutes ago"): any number is always followed by
      # a unit, so a number sitting ALONE (key + number, nothing after)
      # can only be the newer-style epoch.
      if (tok ~ /^[0-9]+$/ && (length(tok) >= 10 || NF == 2)) {
        if (tok + 0 == 0) { print 999999999 }
        else {
          age = now - (tok + 0)
          if (age < 0) age = 0
          print age
        }
        next
      }
      # Human-readable duration: sum the number/unit pairs.
      u["second"]=1; u["sec"]=1; u["seconds"]=1; u["minute"]=60; u["min"]=60; u["minutes"]=60; u["mins"]=60; u["hour"]=3600; u["hours"]=3600;
      u["day"]=86400; u["days"]=86400; u["week"]=604800; u["weeks"]=604800; u["month"]=2592000; u["months"]=2592000; u["year"]=31536000; u["years"]=31536000;
      total=0; num="";
      for(i=1;i<=NF;i++){
        if($i=="never"){ total=999999999 }
        else if($i~/^[0-9]+$/) { num=$i }
        else if(($i in u) && num!=""){ total+=num*u[$i]; num="" }
      }
      print total
    }' | sort -rn | head -1)

[ -n "${age}" ] && printf '%s\n' "${age}"
exit 0
