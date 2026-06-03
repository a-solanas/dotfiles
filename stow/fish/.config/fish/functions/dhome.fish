function dhome --description "Both monitors: DP-1 primary left, DP-2 secondary right"
    kscreen-doctor \
        output.DP-1.enable output.DP-1.priority.1 output.DP-1.position.0,0 \
        output.DP-2.enable output.DP-2.priority.2 output.DP-2.position.2560,0
end
