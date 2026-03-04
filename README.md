# Workspace

Collection of bash scripts that work for both Linux and Mac. Meant for robot 56, but should work with anything. Make sure you are on the same network as the robot. Also, make sure you have `sshpass` installed:

```bash
# Linux (Debian/Ubuntu)
sudo apt install sshpass

# Mac
brew install esolitos/ipa/sshpass
```




## Step Zero: Logging In
For convenience, there are two bash scripts to instantly log in to the robot, given you are on the same network:


```bash
bash login.sh # Puts you directly into the robot's SSH
bash login_docker.sh # Assuming the docker container is running, puts you in docker SSH
```

No password necessary. Just run them. `sshpass` handles the password automatically.


## Step One: Start the Robot
First, connect to the same Wi-Fi network as the robot. Then run this command to start `run_rostorch` and `teleop` in a tmux instance on the robot:

```bash
./start.sh
```

This just runs `run_rostorch` and `teleop` in a tmux instance. You can use `login.sh`, then run `tmux attach` to access it.


## Step Two: Upload Your Package
There is a script that automatically pushes an entire directory to the robot:

```bash
./upload.sh safety_controller_pkg # Shows up as  ~/racecar_ws/src/safety_controller_pkg/
./upload.sh safety_controller_pkg ~/custom/    # ~/custom/safety_controller_pkg/
```

This script:
1. Archives the directory with `tar` and uploads it to the robot via `scp`
2. If the folder already exists on the robot, it **deletes it**
3. Unpacks the transmitted `.tar.gz` to that directory
4. Cleans up the temporary files


Seamless. Make changes locally on your computer, then run this command.


## Step Three: Build Your Package
```
cd ~/racecar_ws
colcon build --packages-select safety_controller_pkg
source install/setup.bash
```

There is a `build.sh` script in `~/racecar_ws` that does this automatically. Run it with `. build.sh` (not `bash build.sh`).

## Step Four: Run
Make sure you've run `start.sh`, or visually confirm in the tmux instance that teleop is running. Then run your package in the Docker container (`login_docker.sh`):

```bash
ros2 run safety_controller_pkg safety_controller_pkg
```

Hold **LB** on the controller for manual control of the robot.

Hold **RB** on the controller to let the autonomous package control the motors. **Note: This doesn't stop `ros2 run`. It only prevents the packages from sending motor signals to the robot.**
