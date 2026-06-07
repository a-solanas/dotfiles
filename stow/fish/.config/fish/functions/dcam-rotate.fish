function dcam-rotate --description "Pipe DroidCam feed rotated 90° CCW to /dev/video3"
    ffmpeg -i /dev/video2 -vf "transpose=2" -pix_fmt yuv420p -f v4l2 /dev/video3
end
