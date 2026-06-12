function dcam --description "Set up DroidCam with rotated v4l2 loopback"
    echo "[1/3] Loading v4l2loopback devices..."
    sudo modprobe -r v4l2loopback 2>/dev/null
    sudo modprobe v4l2loopback video_nr=2,3 card_label="DroidCam,DroidCam-Rotated" exclusive_caps=1
    or begin
        echo "ERROR: Failed to load v4l2loopback. Try: dkms status | grep v4l2"
        return 1
    end
    echo "      /dev/video2 (DroidCam input) and /dev/video3 (rotated output) ready."

    echo "[2/3] Open DroidCam, connect your phone, then press Enter."
    read -P "      > " _

    echo "[3/3] Starting rotation pipe — Ctrl+C to stop."
    echo "      Point your app at 'DroidCam-Rotated' (/dev/video3)."
    ffmpeg -f v4l2 -i /dev/video2 -vf "transpose=2" -pix_fmt yuv420p -f v4l2 /dev/video3 -loglevel warning
end
