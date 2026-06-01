# pwner/ is a separate concern, not a distro variant

Offensive security environments live under `scripts/pwner/` rather than alongside the regular distro scripts. Although Kali is Debian-based and a custom offensive Debian also uses `apt`, the distinguishing axis is use-case (offensive security tooling on a dedicated machine or VM), not package manager. Folding them into `scripts/apt/` would imply they are just another daily-driver Debian variant, which they are not. `pwner/` makes the intent immediately clear and keeps offensive tooling isolated from regular Bootstrap flows.
