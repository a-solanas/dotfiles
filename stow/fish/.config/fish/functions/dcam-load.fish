function dcam-load --description "Load v4l2loopback devices for DroidCam"
    sudo modprobe v4l2loopback video_nr=2,3 card_label="DroidCam,DroidCam-Rotated" exclusive_caps=1
end
