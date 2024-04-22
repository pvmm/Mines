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
proc printf__c {addr}     { puts -nonewline [format "%c"       [peek [peek16 $addr]]] }
proc printf__s {num addr} { puts -nonewline [format "%${num}s" [addr2string [peek16 [peek16 $addr]]]] }
proc printf__S {num addr} { puts -nonewline [format "%${num}s" [string toupper [addr2string [peek16 [peek16 $addr]]]]] }
proc printf__hhi {addr}   { puts -nonewline [format "%hi"      [peek8  [peek16 $addr]]] }
proc printf__hi  {addr}   { puts -nonewline [format "%hi"      [peek16 [peek16 $addr]]] }
proc printf__i   {addr}   { printf__hi $addr }
proc printf__hhu {addr}   { puts -nonewline [format "%hu"      [peek8  [peek16 $addr]]] }
proc printf__hu  {addr}   { puts -nonewline [format "%hu"      [peek16 [peek16 $addr]]] }
proc printf__u   {addr}   { printf__hu $addr }
proc printf__hhx {addr}   { puts -nonewline [format "%hx"      [peek8  [peek16 $addr]]] }
proc printf__hx  {addr}   { puts -nonewline [format "%hx"      [peek16 [peek16 $addr]]] }
proc printf__x   {addr}   { printf__hx $addr }
proc printf__hhX {addr}   { puts -nonewline [format "%hX"      [peek8  [peek16 $addr]]] }
proc printf__hX  {addr}   { puts -nonewline [format "%hX"      [peek16 [peek16 $addr]]] }
proc printf__X   {addr}   { printf__hX $addr }
proc printf__hho {addr}   { puts -nonewline [format "%ho"      [peek8  [peek16 $addr]]] }
proc printf__ho  {addr}   { puts -nonewline [format "%ho"      [peek16 [peek16 $addr]]] }
proc printf__o   {addr}   { printf__ho $addr }
proc printf__hhb {addr}   { puts -nonewline [format "%hb"      [peek8  [peek16 $addr]]] }
proc printf__hb  {addr}   { puts -nonewline [format "%hb"      [peek16 [peek16 $addr]]] }
proc printf__b   {addr}   { printf__hb $addr }

proc printf {addr} {
    global ppos
    set fmt_addr [peek16 $addr]
    set ending_addr $fmt_addr
    set arg_addr [expr $addr + 2]
    set pad   ""  ;# padded string
    set trunc ""  ;# truncated string
    set isize ""  ;# integer size
    set raw   ""

    for {set byte [peek $ending_addr]} {$byte > 0} {incr ending_addr; set byte [peek $ending_addr]} {
        set c [format "%c" $byte]
        switch $c {
            "%" { if {$ppos eq 1} { incr ppos -1; append raw $c } else { incr ppos } }
            "c" { if {$ppos eq 1} { incr ppos -1; set cmd "[printf__c         $arg_addr]"; set pad ""; incr arg_addr 2 } else { append raw $c } }
            "S" { if {$ppos > 0}  {   set ppos 0; set cmd "[printf__S         $pad$trunc $arg_addr]"; set pad ""; set trunc ""; incr arg_addr 2 } else { append raw $c } }
            "s" { if {$ppos > 0}  {   set ppos 0; set cmd "[printf__s         $pad$trunc $arg_addr]"; set pad ""; set trunc ""; incr arg_addr 2 } else { append raw $c } }
            "i" { if {$ppos > 0}  {   set ppos 0; set cmd "[printf__${isize}i $arg_addr]"; set pad ""; incr arg_addr 2 } else { append raw $c } }
            "d" { if {$ppos > 0}  {   set ppos 0; set cmd "[printf__${isize}i $arg_addr]"; set pad ""; incr arg_addr 2 } else { append raw $c } }
            "u" { if {$ppos > 0}  {   set ppos 0; set cmd "[printf__${isize}u $arg_addr]"; set pad ""; incr arg_addr 2 } else { append raw $c } }
            "x" { if {$ppos > 0}  {   set ppos 0; set cmd "[printf__${isize}x $arg_addr]"; set pad ""; incr arg_addr 2 } else { append raw $c } }
            "X" { if {$ppos > 0}  {   set ppos 0; set cmd "[printf__${isize}X $arg_addr]"; set pad ""; incr arg_addr 2 } else { append raw $c } }
            "o" { if {$ppos > 0}  {   set ppos 0; set cmd "[printf__${isize}o $arg_addr]"; set pad ""; incr arg_addr 2 } else { append raw $c } }
            "b" { if {$ppos > 0}  {   set ppos 0; set cmd "[printf__${isize}b $arg_addr]"; set pad ""; incr arg_addr 2 } else { append raw $c } }
            "h" { if {$ppos > 0}  { append isize $c; incr ppos } }
            default {
                if {$ppos > 0 && $byte eq 45} {
                    append truc $c
                    append ppos
                } elseif {$ppos eq 1 && $byte eq 46} {
                    append pad $c
                    append ppos
                } elseif {$ppos eq 1 && $byte >= 48 && $byte <= 57} {
                    append pad $c
                    append ppos
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
