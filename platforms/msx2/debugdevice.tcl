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
proc printf__i {addr}     { puts -nonewline [format "%i"       [peek16 [peek16 $addr]]] }

proc printf {addr} {
    global ppos
    set fmt_addr [peek16 $addr]
    set ending_addr $fmt_addr
    set arg_addr [expr $addr + 2]
    set pad   ""  ;# padded string
    set trunc ""  ;# truncated string
    set raw   ""

    for {set byte [peek $ending_addr]} {$byte > 0} {incr ending_addr; set byte [peek $ending_addr]} {
        set c [format "%c" $byte]
        switch $c {
            "%" { if {$ppos eq 1} { incr ppos -1; append raw $c } else { incr ppos } }
            "c" { if {$ppos eq 1} { incr ppos -1; set command "[printf__c $arg_addr]"; set pad ""; incr arg_addr 2 } else { append raw $c } }
            "S" { if {$ppos > 0}  {   set ppos 0; set command "[printf__S $pad$trunc $arg_addr]"; set pad ""; set trunc ""; incr arg_addr 2 } else { append raw $c } }
            "s" { if {$ppos > 0}  {   set ppos 0; set command "[printf__s $pad$trunc $arg_addr]"; set pad ""; set trunc ""; incr arg_addr 2 } else { append raw $c } }
            "i" { if {$ppos eq 1} { incr ppos -1; set command "[printf__i $arg_addr]"; set pad ""; incr arg_addr 2 } else { append raw $c } }
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
        if {[info exists command]} {
            puts -nonewline $raw; set raw ""
            eval $command
            unset command
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
    set use_pause $::env(DEBUG)
    #ext debugdevice
    debug set_watchpoint write_io {0x2e} {} {process_input $::wp_last_value}
    debug set_watchpoint write_io {0x2f} {} {print_input $::wp_last_value}
}

bind "mouse button2 down" toggle grabinput
plug joyporta mouse
