gen::add_generator "C#" gen_cs::generate

namespace eval gen_cs {



# Autogenerated with DRAKON Editor 1.23

proc bad_case { switch_var select_icon_number } {
    #item 1308
    if {[ string compare -nocase $switch_var "select" ] == 0} {
        #item 1311
        return "throw new InvalidOperationException\(\"Condition was not detected.\");"
    } else {
        #item 573
        return "throw new InvalidOperationException\(\"Not expected:  \" + ${switch_var}.ToString()\);"
    }
}

proc change_state { next_state machine_name } {
    #item 1095
    if {$next_state == ""} {
        #item 1099
        return "_state = Finished_State;"
    } else {
        #item 1098
        return "_state = ${next_state}_State;"
    }
}

proc classify_keywords { keywords name } {
    #item 788
    set errors {}
    #item 742
    set access [ gen_cpp::find_keywords $keywords { private public protected internal } ]
    #item 7500000
    set _sw7500000_ [ llength $access ]
    #item 7500001
    if {($_sw7500000_ == 0) || ($_sw7500000_ == 1)} {
        
    } else {
        #item 744
        lappend errors "$name: inconsistent access: $access"
    }
    #item 746
    set dispatch [ gen_cpp::find_keywords $keywords { override abstract static virtual } ]
    #item 7620000
    set _sw7620000_ [ llength $dispatch ]
    #item 7620001
    if {$_sw7620000_ == 0} {
        #item 761
        set dispatch "normal"
    } else {
        #item 7620002
        if {$_sw7620000_ == 1} {
            
        } else {
            #item 754
            lappend errors "$name: inconsistent dispatch: $dispatch"
        }
    }
    #item 772
    set subtype [ gen_cpp::find_keywords $keywords { method ctr } ]
    #item 7730000
    set _sw7730000_ [ llength $subtype ]
    #item 7730001
    if {$_sw7730000_ == 0} {
        #item 771
        set subtype "method"
    } else {
        #item 7730002
        if {$_sw7730000_ == 1} {
            
        } else {
            #item 764
            lappend errors "$name: inconsistent method type: $subtype"
        }
    }
    #item 7750001
    if {(($subtype == "method") || (!($subtype == "ctr"))) || ($dispatch == "normal")} {
        
    } else {
        #item 820
        lappend errors \
        "$name: constructor cannot be $dispatch"
    }
    #item 837
    if {$access == ""} {
        #item 838
        set access "none"
    } else {
        
    }
    #item 866
    array set props {}
    #item 867
    set props(access) $access
    set props(dispatch) $dispatch
    set props(type) $subtype
    #item 868
    set proplist [ array get props ]
    set error_message [ join $errors "\n" ]
    #item 869
    return [ list $error_message $proplist ]
}

proc extract_class_name { section } {
    #item 957
    set section [ string map { "\{" " " } $section ]
    set section [ split $section " \t\n" ]
    #item 940
    set count [ llength $section ]
    #item 941
    if {$count < 2} {
        #item 955
        return ""
    } else {
        #item 944
        set found [ lsearch $section "class" ]
        #item 945
        if {$found == -1} {
            #item 949
            set found [ lsearch $section "struct" ]
            #item 950
            if {$found == -1} {
                #item 955
                return ""
            } else {
                #item 951
                set name_pos [ expr { $found + 1 } ]
                #item 954
                if {$name_pos < $count} {
                    #item 956
                    return [ lindex $section $name_pos ]
                } else {
                    #item 955
                    return ""
                }
            }
        } else {
            #item 951
            set name_pos [ expr { $found + 1 } ]
            #item 954
            if {$name_pos < $count} {
                #item 956
                return [ lindex $section $name_pos ]
            } else {
                #item 955
                return ""
            }
        }
    }
}

proc extract_signature { text name } {
    #item 710
    array set props { 
    	access none 
    	dispatch normal
    	type method
    }
    set error_message ""
    set parameters {}
    set returns ""
    set type "method"
    #item 669
    set lines [ gen::separate_from_comments $text ]
    #item 671
    if {[ llength $lines ] == 0} {
        
    } else {
        #item 670
        set first_line [ lindex $lines 0 ]
        set first [ lindex $first_line 0 ]
        #item 693
        if {$first == "#comment"} {
            #item 683
            set type "comment"
        } else {
            #item 699
            set keywords { 
            	public private protected internal
            	override abstract static virtual
            	method ctr
            }
            #item 700
            set found_keywords [ gen_cpp::find_keywords $first $keywords ]
            #item 698
            if {[ llength $found_keywords ] == 0} {
                #item 702
                set start_index 0
                #item 678
                set count [ llength $lines ]
                #item 6810001
                set i $start_index
                while { 1 } {
                    #item 6810002
                    if {$i < $count} {
                        
                    } else {
                        break
                    }
                    #item 680
                    set current [ lindex $lines $i ]
                    set stripped [ lindex $current 0 ]
                    #item 686
                    if {[ string match "returns *" $stripped ]} {
                        #item 888
                        set returns [ gen_cpp::extract_return_type $stripped ]
                    } else {
                        #item 685
                        lappend parameters $current
                    }
                    #item 6810003
                    incr i
                }
            } else {
                #item 701
                set start_index 1
                #item 704
                set alien_keywords [ gen_cpp::find_not_belonging $first $keywords ]
                #item 705
                if {[ llength $alien_keywords ] == 0} {
                    #item 711
                    unpack [ classify_keywords $found_keywords $name ] \
                    	error_message prop_list
                    #item 712
                    if {$error_message == ""} {
                        #item 713
                        array unset props
                        array set props $prop_list
                        set type $props(type)
                        #item 678
                        set count [ llength $lines ]
                        #item 6810001
                        set i $start_index
                        while { 1 } {
                            #item 6810002
                            if {$i < $count} {
                                
                            } else {
                                break
                            }
                            #item 680
                            set current [ lindex $lines $i ]
                            set stripped [ lindex $current 0 ]
                            #item 686
                            if {[ string match "returns *" $stripped ]} {
                                #item 888
                                set returns [ gen_cpp::extract_return_type $stripped ]
                            } else {
                                #item 685
                                lappend parameters $current
                            }
                            #item 6810003
                            incr i
                        }
                    } else {
                        
                    }
                } else {
                    #item 706
                    set error_message \
                        "$name: Unexpected keywords: $alien_keywords"
                }
            }
        }
    }
    #item 897
    if {$type == "ctr"} {
        #item 898
        if {$returns == ""} {
            
        } else {
            #item 899
            set error_message \
            "$name: constructors must not have return type"
        }
    } else {
        #item 902
        if {$returns == ""} {
            #item 905
            set returns "void"
        } else {
            
        }
    }
    #item 714
    set prop_list [ array get props ]
    #item 682
    set signature [ gen::create_signature $type $prop_list $parameters $returns ]
    set result [ list $error_message $signature ]
    #item 896
    return $result
}

proc foreach_check { item_id first second } {
    #item 1057
    set iter_var "_it$item_id"
    #item 1055
    return "$iter_var.MoveNext()"
}

proc foreach_current { item_id first second } {
    #item 1059
    unpack [ parse_foreach $item_id $first ] type var
    #item 1058
    set iter_var "_it$item_id"
    
    return "$var = $iter_var.Current;"
}

proc foreach_declare { item_id first second } {
    #item 1067
    unpack [ parse_foreach $item_id $first ] type var
    #item 1066
    set iter_var "_it$item_id"
    set iter_type "IEnumerator<$type>"
    
    
    return "$iter_type $iter_var = null;\n$type $var = default\($type\);"
}

proc foreach_incr { item_id first second } {
    #item 32
    return ""
}

proc foreach_init { item_id first second } {
    #item 1054
    unpack [ parse_foreach $item_id $first ] type var
    #item 19
    set iter_var "_it$item_id"
    set col_type "IEnumerable<$type>"
    
    
    return "$iter_var = \(\($col_type\)$second\).GetEnumerator();"
}

proc generate { db gdb filename } {
    #item 337
    set callbacks [ make_callbacks ]
    #item 1252
    lassign [ gen::scan_file_description $db \
     { header class footer } ] \
     header class footer
    #item 1085
    set machine [ sma::extract_machine $gdb $callbacks ]
    #item 1089
    set diagrams [ $gdb eval {
    	select diagram_id from diagrams } ]
    #item 10870001
    set _col1087 $diagrams
    set _len1087 [ llength $_col1087 ]
    set _ind1087 0
    while { 1 } {
        #item 10870002
        if {$_ind1087 < $_len1087} {
            
        } else {
            break
        }
        #item 10870004
        set diagram_id [ lindex $_col1087 $_ind1087 ]
        #item 1248
        if {[mwc::is_drakon $diagram_id]} {
            #item 1086
            gen::fix_graph_for_diagram $gdb $callbacks 1 $diagram_id
        } else {
            
        }
        #item 10870003
        incr _ind1087
    }
    #item 1243
    tab::generate_tables $gdb $callbacks 0
    #item 1244
    if {[graph::errors_occured]} {
        
    } else {
        #item 349
        set nogoto 1
        set all_functions [ gen::generate_functions \
         $db $gdb $callbacks $nogoto ]
        #item 734
        if {$class == ""} {
            #item 735
            error \
            "Please add the ===class=== section to the file description."
        } else {
            #item 338
            if {[ graph::errors_occured ]} {
                
            } else {
                #item 927
                set class_name [ extract_class_name $class ]
                #item 928
                if {$class_name == ""} {
                    #item 929
                    error \
                    "Class or struct is missing in the ===class=== section."
                } else {
                    #item 1254
                    separate_methods $all_functions functions methods
                    #item 339
                    set hfile [ replace_extension $filename "cs" ]
                    set fhandle [ open $hfile w ]
                    catch {
                    	p.print_to_file $fhandle $functions \
                    		$methods \
                    		$header $class $class_name $footer \
                    		$machine
                    } error_message
                    set details $::errorInfo
                    catch { close $fhandle }
                    #item 340
                    if {$error_message == ""} {
                        
                    } else {
                        #item 1253
                        puts $details
                        #item 341
                        error $error_message
                    }
                }
            }
        }
    }
}

proc generate_body { gdb diagram_id start_item node_list items incoming } {
    #item 590
    set callbacks [ make_callbacks ]
    #item 591
    return [ cbody::generate_body $gdb $diagram_id $start_item $node_list \
    $items $incoming $callbacks ]
}

proc is_ctr { method } {
    #item 911
    set signature [ lindex $method 2 ]
    set type [ lindex $signature 0 ]
    return [ expr { $type == "ctr" } ]
}

proc make_callbacks { } {
    #item 641
    set callbacks {}
    
    gen::put_callback callbacks assign			gen_java::assign
    gen::put_callback callbacks compare			gen_java::compare
    gen::put_callback callbacks compare2		gen_java::compare
    gen::put_callback callbacks while_start 	gen_java::while_start
    gen::put_callback callbacks if_start		gen_java::if_start
    gen::put_callback callbacks elseif_start	gen_java::elseif_start
    gen::put_callback callbacks if_end			gen_java::if_end
    gen::put_callback callbacks else_start		gen_java::else_start
    gen::put_callback callbacks pass			gen_java::pass
    gen::put_callback callbacks continue		gen_java::p.continue
    gen::put_callback callbacks return_none		gen_java::return_none
    gen::put_callback callbacks block_close		gen_java::block_close
    gen::put_callback callbacks comment			gen_java::commentator
    
    gen::put_callback callbacks break			"break;"
    gen::put_callback callbacks and				gen_java::p.and
    gen::put_callback callbacks or				gen_java::p.or
    gen::put_callback callbacks not				gen_java::p.not
    gen::put_callback callbacks declare		gen_java::p.declare
    
    
    gen::put_callback callbacks bad_case		gen_cs::bad_case
    
    gen::put_callback callbacks body			gen_cs::generate_body
    gen::put_callback callbacks signature		gen_cs::extract_signature
    	
    gen::put_callback callbacks for_check		gen_cs::foreach_check
    gen::put_callback callbacks for_current		gen_cs::foreach_current
    gen::put_callback callbacks for_init		gen_cs::foreach_init
    gen::put_callback callbacks for_incr		gen_cs::foreach_incr
    gen::put_callback callbacks for_declare		gen_cs::foreach_declare
    gen::put_callback callbacks shelf gen_cs::shelf
    gen::put_callback callbacks change_state gen_cs::change_state
    gen::put_callback callbacks fsm_merge   0
    #item 650
    return $callbacks
}

proc method_of_access { procedure access } {
    #item 1041
    set signature [ lindex $procedure 2 ]
    set type [ lindex $signature 0 ]
    #item 918
    if {$type == "method"} {
        #item 923
        set props_list [ lindex $signature 1 ]
        array set props $props_list
        #item 924
        if {$props(access) == $access} {
            #item 921
            return 1
        } else {
            #item 922
            return 0
        }
    } else {
        #item 922
        return 0
    }
}

proc p.print_proc { fhandle procedure class_name depth } {
    #item 97
    unpack $procedure diagram_id name signature body
    #item 968
    if {$class_name == ""} {
        
    } else {
        #item 971
        set name $class_name
    }
    #item 972
    unpack $signature type prop_list parameters returns
    array set props $prop_list
    #item 66
    set indent [ gen::make_indent $depth ]
    #item 67
    set body_depth [ expr { $depth + 1 } ]
    set lines [ gen::indent $body $body_depth ]
    #item 985
    set header ""
    #item 1074
    if {$props(access) == "none"} {
        
    } else {
        #item 995
        append header "$props(access) "
    }
    #item 1071
    if {$props(dispatch) == "normal"} {
        
    } else {
        #item 1007
        append header "$props(dispatch) "
    }
    #item 1011
    if {$type == "ctr"} {
        
    } else {
        #item 1014
        append header "$returns "
    }
    #item 1015
    append header "$name\("
    #item 1021
    set i 0
    #item 10190001
    set _col1019 $parameters
    set _len1019 [ llength $_col1019 ]
    set _ind1019 0
    while { 1 } {
        #item 10190002
        if {$_ind1019 < $_len1019} {
            
        } else {
            break
        }
        #item 10190004
        set parameter [ lindex $_col1019 $_ind1019 ]
        #item 1024
        if {$i == 0} {
            
        } else {
            #item 1027
            append header ", "
        }
        #item 1023
        set arg [ lindex $parameter 0 ]
        append header $arg
        #item 1022
        incr i
        #item 10190003
        incr _ind1019
    }
    #item 1031
    append header "\)"
    #item 1036
    puts $fhandle ""
    #item 1033
    if {$props(dispatch) == "abstract"} {
        #item 1037
        puts $fhandle "$indent$header;"
    } else {
        #item 96
        puts $fhandle "$indent$header \{"
        puts $fhandle $lines
        puts $fhandle "$indent\}"
    }
}

proc p.print_to_file { fhandle functions methods header class class_name footer machine } {
    #item 400
    set version [ version_string ]
    puts $fhandle \
        "// Autogenerated with DRAKON Editor $version"
    #item 68
    puts $fhandle $header
    #item 925
    puts $fhandle $class
    #item 1101
    print_machine $fhandle $machine $class_name
    #item 1247
    init_current_file $fhandle
    generate_data_struct $class_name $methods
    #item 926
    set ctrs      [ lfilter $functions gen_java::is_ctr ]
    set public    [ lfilter_user $functions gen_java::method_of_access "public"    ]
    set none      [ lfilter_user $functions gen_java::method_of_access "none"      ]
    set protected [ lfilter_user $functions gen_java::method_of_access "protected" ]
    set private   [ lfilter_user $functions gen_java::method_of_access "private"   ]
    set internal  [ lfilter_user $functions gen_java::method_of_access "internal"  ]
    #item 966
    print_procs $fhandle $ctrs $class_name 1
    #item 967
    print_procs $fhandle $public "" 1
    print_procs $fhandle $internal "" 1
    print_procs $fhandle $protected "" 1
    print_procs $fhandle $private "" 1
    print_procs $fhandle $none "" 1
    #item 76
    puts $fhandle "\}"
    #item 1068
    puts $fhandle $footer
}

proc parse_foreach { item_id init } {
    #item 1048
    set length [ llength $init ]
    #item 1050
    if {$length == 2} {
        
    } else {
        #item 1049
        set message "item id: $item_id, wrong syntax in foreach. Should be: Type variable; collection"
    }
    #item 1053
    return $init
}

proc print_bad { fhandle state method class_name } {
    #item 1160
    set message "\"$class_name: Method '$method' is not expected in state '$state'.\""
    #item 1161
    puts $fhandle "        throw new System.InvalidOperationException\($message\);"
    puts $fhandle "    \}"
}

proc print_good { fhandle state param_names } {
    #item 1153
    set arg_list [ join $param_names ", " ]
    set method "${state}_default"
    #item 1154
    puts $fhandle "        $method\($arg_list\);"
    puts $fhandle "    \}"
}

proc print_header { fhandle state message parameters } {
    #item 1147
    set arg_list [ join $parameters ", " ]
    #item 1146
    puts $fhandle "    private void ${state}_${message}\($arg_list\)"
    puts $fhandle "    \{"
}

proc print_machine { fhandle machine class_name } {
    #item 1116
    if {$machine == {}} {
        
    } else {
        #item 1120
        set parameters [ dict get $machine "parameters" ]
        set param_names [ dict get $machine "param_names" ]
        set last [ dict get $machine "last" ]
        set boiler [ dict get $machine "boiler" ]
        set messages [ dict get $machine "messages" ]
        set states [ dict get $machine "states" ]
        #item 1175
        set first_state_name [ lindex $states 0 ]
        set first_state "${first_state_name}_State"
        set iface "I${class_name}_State"
        #item 1165
        puts $fhandle "    public interface $iface"
        puts $fhandle "    \{"
        puts $fhandle "        string Name \{ get; \}"
        #item 1168
        set params2 [ linsert $parameters 0 "$class_name obj" ]
        set arg_list2 [ join $params2 ", " ]
        #item 11690001
        set _col1169 $messages
        set _len1169 [ llength $_col1169 ]
        set _ind1169 0
        while { 1 } {
            #item 11690002
            if {$_ind1169 < $_len1169} {
                
            } else {
                break
            }
            #item 11690004
            set message [ lindex $_col1169 $_ind1169 ]
            #item 1171
            puts $fhandle "        void $message\($arg_list2\);"
            #item 11690003
            incr _ind1169
        }
        #item 1166
        puts $fhandle "    \}"
        puts $fhandle "    private $iface _state = $first_state;"
        puts $fhandle "    public $iface State \{ get \{ return _state; \} \}"
        #item 1190
        set arg_name_list [ join $param_names ", " ]
        #item 11810001
        set _col1181 $states
        set _len1181 [ llength $_col1181 ]
        set _ind1181 0
        while { 1 } {
            #item 11810002
            if {$_ind1181 < $_len1181} {
                
            } else {
                break
            }
            #item 11810004
            set state [ lindex $_col1181 $_ind1181 ]
            #item 1218
            set lines {}
            #item 12190001
            set _col1219 $messages
            set _len1219 [ llength $_col1219 ]
            set _ind1219 0
            while { 1 } {
                #item 12190002
                if {$_ind1219 < $_len1219} {
                    
                } else {
                    break
                }
                #item 12190004
                set message [ lindex $_col1219 $_ind1219 ]
                #item 1189
                set line "obj.${state}_${message}\($arg_name_list\);"
                lappend lines $line
                #item 12190003
                incr _ind1219
            }
            #item 1208
            print_state_class $fhandle $messages $iface $state $arg_list2 $lines
            #item 11810003
            incr _ind1181
        }
        #item 1210
        if {$last} {
            #item 1213
            set line "throw new System.InvalidOperationException\(\"The '$class_name' object is in the finished state.\"\);"
            #item 1209
            print_special_state_class $fhandle $messages $iface "Finished" $arg_list2 $line
        } else {
            
        }
        #item 1215
        set line "throw new System.InvalidOperationException\(\"The '$class_name' object is in the intermediate state.\"\);"
        #item 1214
        print_special_state_class $fhandle $messages $iface "Intermediate" $arg_list2 $line
        #item 1167
        set arg_list [ join $parameters ", " ]
        #item 11720001
        set _col1172 $messages
        set _len1172 [ llength $_col1172 ]
        set _ind1172 0
        while { 1 } {
            #item 11720002
            if {$_ind1172 < $_len1172} {
                
            } else {
                break
            }
            #item 11720004
            set message [ lindex $_col1172 $_ind1172 ]
            #item 1174
            print_state_method $fhandle $message $arg_list $param_names $iface
            #item 11720003
            incr _ind1172
        }
        #item 11300001
        set _col1130 $states
        set _len1130 [ llength $_col1130 ]
        set _ind1130 0
        while { 1 } {
            #item 11300002
            if {$_ind1130 < $_len1130} {
                
            } else {
                break
            }
            #item 11300004
            set state [ lindex $_col1130 $_ind1130 ]
            #item 1132
            set stub_info [ dict get $boiler $state ]
            set good [ dict get $stub_info "good" ]
            set bad [ dict get $stub_info "bad" ]
            #item 11350001
            set _col1135 $good
            set _len1135 [ llength $_col1135 ]
            set _ind1135 0
            while { 1 } {
                #item 11350002
                if {$_ind1135 < $_len1135} {
                    
                } else {
                    break
                }
                #item 11350004
                set good_method [ lindex $_col1135 $_ind1135 ]
                #item 1134
                print_header $fhandle $state $good_method $parameters
                print_good $fhandle $state $param_names
                #item 11350003
                incr _ind1135
            }
            #item 11390001
            set _col1139 $bad
            set _len1139 [ llength $_col1139 ]
            set _ind1139 0
            while { 1 } {
                #item 11390002
                if {$_ind1139 < $_len1139} {
                    
                } else {
                    break
                }
                #item 11390004
                set bad_method [ lindex $_col1139 $_ind1139 ]
                #item 1138
                print_header $fhandle $state $bad_method $parameters
                print_bad $fhandle $state $bad_method $class_name
                #item 11390003
                incr _ind1139
            }
            #item 11300003
            incr _ind1130
        }
    }
}

proc print_procs { fhandle procedures class_name depth } {
    #item 9630001
    set _col963 $procedures
    set _len963 [ llength $_col963 ]
    set _ind963 0
    while { 1 } {
        #item 9630002
        if {$_ind963 < $_len963} {
            
        } else {
            break
        }
        #item 9630004
        set procedure [ lindex $_col963 $_ind963 ]
        #item 965
        p.print_proc $fhandle $procedure $class_name $depth
        #item 9630003
        incr _ind963
    }
}

proc print_special_state_class { fhandle messages iface name parameters line } {
    #item 1238
    set lines {}
    set count [ llength $messages ]
    #item 12390001
    set i 0
    while { 1 } {
        #item 12390002
        if {$i < $count} {
            
        } else {
            break
        }
        #item 1241
        lappend lines $line
        #item 12390003
        incr i
    }
    #item 1242
    print_state_class $fhandle $messages $iface $name $parameters $lines
}

proc print_state_class { fhandle messages iface name parameters lines } {
    #item 1202
    set sname "${name}_State_Definition"
    puts $fhandle "    private class $sname : $iface \{"
    puts $fhandle "        public string Name \{ get \{ return \"$name\"; \} \}"
    #item 1221
    set i 0
    #item 12040001
    set _col1204 $messages
    set _len1204 [ llength $_col1204 ]
    set _ind1204 0
    while { 1 } {
        #item 12040002
        if {$_ind1204 < $_len1204} {
            
        } else {
            break
        }
        #item 12040004
        set message [ lindex $_col1204 $_ind1204 ]
        #item 1206
        puts $fhandle "        public void $message\($parameters\) \{"
        #item 1223
        set line [ lindex $lines $i ]
        #item 1207
        puts $fhandle "            $line"
        puts $fhandle "        \}"
        #item 1222
        incr i
        #item 12040003
        incr _ind1204
    }
    #item 1203
    puts $fhandle "    \}"
    puts $fhandle "    public static readonly $iface ${name}_State = new $sname\(\);"
}

proc print_state_method { fhandle message parameters param_names iface } {
    #item 1217
    set all_arg_names [ linsert $param_names 0 "this" ]
    set arg_list [ join $all_arg_names ", " ]
    #item 1216
    puts $fhandle "    public void ${message}\($parameters\) \{"
    puts $fhandle "        $iface current = _state;"
    puts $fhandle "        _state = Intermediate_State;"
    puts $fhandle "        current.${message}\($arg_list\);"
    puts $fhandle "    \}"
}

proc separate_methods { all_functions functions_name methods_name } {
    #item 1270
    upvar $functions_name functions
    upvar $methods_name methods
    #item 1275
    array set methods_by_class {}
    set functions {}
    #item 12710001
    set _col1271 $all_functions
    set _len1271 [ llength $_col1271 ]
    set _ind1271 0
    while { 1 } {
        #item 12710002
        if {$_ind1271 < $_len1271} {
            
        } else {
            break
        }
        #item 12710004
        set function [ lindex $_col1271 $_ind1271 ]
        #item 1274
        lassign $function diagram_id name signature body
        #item 1273
        lassign \
        [try_parse_method_name $diagram_id $name] \
        class_name method_name is_method
        #item 1276
        if {$is_method} {
            #item 1279
            set class [ tab::find_class $class_name ]
            #item 1280
            if {$class == ""} {
                #item 1284
                gen::report_error $diagram_id {} \
                "Unknown class: '$class_name'"
            } else {
                #item 1286
                if {[info exists methods_by_class($class)]} {
                    #item 1290
                    set class_methods $methods_by_class($class)
                } else {
                    #item 1289
                    set class_methods {}
                }
                #item 1307
                set function2 [ list \
                 $diagram_id $method_name $signature $body ]
                #item 1285
                lappend class_methods $function2
                set methods_by_class($class) $class_methods
            }
        } else {
            #item 1291
            lappend functions $function
        }
        #item 12710003
        incr _ind1271
    }
    #item 1292
    set methods [ array get methods_by_class ]
}

proc shelf { primary secondary } {
    #item 1080
    return "$secondary = $primary;"
}

proc try_parse_method_name { diagram_id name } {
    #item 1298
    set parts [ split $name "." ]
    #item 1299
    if {[ llength $parts ] == 2} {
        #item 1302
        lassign $parts first second
        #item 1303
        if {($first == "") || ($second == "")} {
            #item 1305
            return [ list "" "" 0 ]
        } else {
            #item 1306
            return [ list $first $second 1 ]
        }
    } else {
        #item 1305
        return [ list "" "" 0 ]
    }
}

}
