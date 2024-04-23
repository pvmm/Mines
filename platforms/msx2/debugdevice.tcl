set debug_mode 1
set npos 0
set int 0
set addr 0
set ppos 0

proc pause_on {} {
    #ext debugdevice
    set use_pause true
    debug set_watchpoint write_io {0x2e} {} {process_input $::wp_last_value}
}

proc pause_off {} {
    #ext debugdevice
    set use_pause false
    debug set_watchpoint write_io {0x2e} {} {}
}

proc process_input {{value 0}} {
    global use_pause
    global debug_mode
    switch $value {
        0xff    { if {$use_pause > 0} { debug break }} 
        default { set debug_mode $value }
    }
    ;#puts stderr "mode $debug_mode set"
}

proc string_size {addr} {
    set start_addr $addr
    for {set byte [peek $addr]} {$byte > 0} {set byte [peek $addr]} {
        incr addr;
    }
    return [expr $addr - $start_addr];
}

proc addr2string {addr} {
    set str ""
    for {set byte [peek $addr]} {$byte > 0} {incr addr; set byte [peek $addr]} {
        append str [format "%c" $byte]
    }
    return $str
}

;# formatting commands
proc printf__c   {mod addr} { puts -nonewline [format "%${mod}c"  [peek [peek16 $addr]]] }
proc printf__s   {mod addr} { puts -nonewline [format "%${mod}s"  [addr2string [peek16 [peek16 $addr]]]] }
proc printf__S   {mod addr} { puts -nonewline [format "%${mod}s"  [string toupper  [addr2string [peek16 [peek16 $addr]]]]] }
proc printf__hhi {mod addr} { puts -nonewline [format "%${mod}hi" [peek8  [peek16 $addr]]] }
proc printf__hi  {mod addr} { puts -nonewline [format "%${mod}hi" [peek16 [peek16 $addr]]] }
proc printf__i   {mod addr} { [printf__hi $mod $addr] }
proc printf__hhu {mod addr} { puts -nonewline [format "%${mod}hu" [peek8  [peek16 $addr]]] }
proc printf__hu  {mod addr} { puts -nonewline [format "%${mod}hu" [peek16 [peek16 $addr]]] }
proc printf__u   {mod addr} { [printf__hu $mod $addr] }
proc printf__hhx {mod addr} { puts -nonewline [format "%${mod}hx" [peek8  [peek16 $addr]]] }
proc printf__hx  {mod addr} { puts -nonewline [format "%${mod}hx" [peek16 [peek16 $addr]]] }
proc printf__x   {mod addr} { [printf__hx $mod $addr] }
proc printf__hhX {mod addr} { puts -nonewline [format "%${mod}hX" [peek8  [peek16 $addr]]] }
proc printf__hX  {mod addr} { puts -nonewline [format "%${mod}hX" [peek16 [peek16 $addr]]] }
proc printf__X   {mod addr} { [printf__hX $mod $addr] }
proc printf__hho {mod addr} { puts -nonewline [format "%${mod}ho" [peek8  [peek16 $addr]]] }
proc printf__ho  {mod addr} { puts -nonewline [format "%${mod}ho" [peek16 [peek16 $addr]]] }
proc printf__o   {mod addr} { [printf__ho $mod $addr] }
proc printf__hhb {mod addr} { puts -nonewline [format "%${mod}hb" [peek8  [peek16 $addr]]] }
proc printf__hb  {mod addr} { puts -nonewline [format "%${mod}hb" [peek16 [peek16 $addr]]] }
proc printf__b   {mod addr} { [printf__hb $mod $addr] }
proc printf__f   {mod addr} { puts -nonewline [format "%${mod}s"  [parse_float [peek16 $addr]]] }
proc printf__z   {mod addr} { puts "mod=$mod" }

proc parse_float {addr} {
    set buf ""
	set exp [peek8 $addr]
	set mantissa [debug read_block memory $addr 3] ;# string
	for {set b 0} {$b < [string length mantissa]} {incr b} {
		set c [scan [string index $mantissa $b] %c]
		append buf $c
	}
	return $buf
}

;# empty variable args
proc e= {args} {
    for {set len 0} {$len < [llength $args]} {incr len} {
        upvar [lindex $args $len] arg; set arg ""
    }
}

proc printf {addr} {
    global ppos
    set fmt_addr [peek16 $addr]
    set ending_addr $fmt_addr
    set arg_addr [expr $addr + 2]
    set neg   ""  ;# negative sign?
    set lpad  ""  ;# pad size in characters
    set dot   ""  ;# truncate dot?
    set rpad  ""  ;# truncated size in characters
    set isize ""  ;# integer size prefix such as hh, h, l
    set raw   ""

    for {set byte [peek $ending_addr]} {$byte > 0} {incr ending_addr; set byte [peek $ending_addr]} {
        set c [format "%c" $byte]
        switch $c {
            "%" { if {$ppos eq 1} { incr ppos -1; append raw $c } else { incr ppos } }
            "c" { if {$ppos > 0}  { set ppos 0; set cmd "[printf__c         $neg$lpad$dot$rpad $arg_addr]"; e= neg lpad dot rpad isize; incr arg_addr 2 } else { append raw $c } }
            "S" { if {$ppos > 0}  { set ppos 0; set cmd "[printf__S         $neg$lpad$dot$rpad $arg_addr]"; e= neg lpad dot rpad isize; incr arg_addr 2 } else { append raw $c } }
            "s" { if {$ppos > 0}  { set ppos 0; set cmd "[printf__s         $neg$lpad$dot$rpad $arg_addr]"; e= neg lpad dot rpad isize; incr arg_addr 2 } else { append raw $c } }
            "i" { if {$ppos > 0}  { set ppos 0; set cmd "[printf__${isize}i $neg$lpad$dot$rpad $arg_addr]"; e= neg lpad dot rpad isize; incr arg_addr 2 } else { append raw $c } }
            "d" { if {$ppos > 0}  { set ppos 0; set cmd "[printf__${isize}i $neg$lpad$dot$rpad $arg_addr]"; e= neg lpad dot rpad isize; incr arg_addr 2 } else { append raw $c } }
            "u" { if {$ppos > 0}  { set ppos 0; set cmd "[printf__${isize}u $neg$lpad$dot$rpad $arg_addr]"; e= neg lpad dot rpad isize; incr arg_addr 2 } else { append raw $c } }
            "x" { if {$ppos > 0}  { set ppos 0; set cmd "[printf__${isize}x $neg$lpad$dot$rpad $arg_addr]"; e= neg lpad dot rpad isize; incr arg_addr 2 } else { append raw $c } }
            "X" { if {$ppos > 0}  { set ppos 0; set cmd "[printf__${isize}X $neg$lpad$dot$rpad $arg_addr]"; e= neg lpad dot rpad isize; incr arg_addr 2 } else { append raw $c } }
            "o" { if {$ppos > 0}  { set ppos 0; set cmd "[printf__${isize}o $neg$lpad$dot$rpad $arg_addr]"; e= neg lpad dot rpad isize; incr arg_addr 2 } else { append raw $c } }
            "b" { if {$ppos > 0}  { set ppos 0; set cmd "[printf__${isize}b $neg$lpad$dot$rpad $arg_addr]"; e= neg lpad dot rpad isize; incr arg_addr 2 } else { append raw $c } }
            "f" { if {$ppos > 0}  { set ppos 0; set cmd "[printf__f         $neg$lpad$dot$rpad $arg_addr]"; e= neg lpad dot rpad isize; incr arg_addr 2 } else { append raw $c } }
            "h" { if {$ppos > 0}  { append isize $c; incr ppos } }
            default {
                if {$ppos eq 1 && $c eq "-"} {
                    append neg $c
                    incr ppos
                } elseif {$ppos > 0 && $c eq "."} {
                    append dot $c
                    incr ppos
                } elseif {$ppos > 0 && $byte >= 48 && $byte <= 57} {
                    if {$dot eq ""} { append lpad $c } else { append rpad $c }
                    incr ppos
                } else {
                    set ppos 0; append raw $c
                }
            }
        }
        if {[info exists cmd]} {
            puts -nonewline $raw; set raw ""
            eval $cmd
            unset cmd
        } else {
            puts -nonewline $raw; set raw ""
        }
    }
    ;#set fmt_string [debug read_block memory $fmt_addr [expr $ending - $fmt_addr - 1]]
    ;#puts $fmt_string
}

proc print_input {{value 0}} {
    global debug_mode
    global npos
    global int
    global addr

    ;#puts stderr "$debug_mode mode"
    switch $debug_mode {
        0 {
            if {$npos == 1} {
                set int [expr {($value << 8) + $int}]
                puts stderr [format "%x" $int]
                set int 0
                incr npos -1
            } else {
                set int $value
                incr npos
            }
        }
        1 {
            if {$npos == 1} {
                set int [expr {($value << 8) + $int}]
                if {$int > 32767} {
                    set int [expr {$int - 65536}]
                }
                puts stderr $int
                set int 0
                incr npos -1
            } else {
                set int $value
                incr npos
            }
        }
        2 {
            if {$npos == 1} {
                set int [expr {($value << 8) + $int}]
                puts stderr [format "0b%b" $int]
                set int 0
                incr npos -1
            } else {
                set int $value
                incr npos
            }
        }
        3 { puts -nonewline stderr [format "%c" $value] }
        4 {
            if {$npos == 1} {
                set addr [expr {($value << 8) + $addr}]
		message "addr = $addr"
		printf $addr
                ;# puts stderr [format "0X%X" $int]
                set addr 0
                incr npos -1
            } else {
                set addr $value
                incr npos
            }
        }
        default {
            puts stderr "? Unknown debug_mode $debug_mode"
        }
    }
}

if { [info exists ::env(DEBUG)] && $::env(DEBUG) > 0 } {
    puts stderr "DEBUG MODE"
    set use_pause $::env(DEBUG)
    #ext debugdevice
    debug set_watchpoint write_io {0x2e} {} {process_input $::wp_last_value}
    debug set_watchpoint write_io {0x2f} {} {print_input $::wp_last_value}
}

ext debugdevice
