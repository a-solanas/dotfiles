function dwork --description "Work mode: secondary screen (DP-2) only"
    kscreen-doctor \
        output.DP-1.disable \
        output.DP-2.enable output.DP-2.priority.1 output.DP-2.position.0,0
end
