# Linux Basics - Crash Course

Essential Linux commands for navigating the De-ICE S1.100 lab environment.

## Getting Started

### What is Linux?
- **Operating System:** Like Windows or macOS, but text-based interface
- **Terminal/Shell:** The black screen where you type commands  
- **Case Sensitive:** `File.txt` and `file.txt` are different files
- **No File Extensions Required:** Files don't need `.exe` to run

### Basic Concepts
- **Root Directory:** `/` is the top level (like `C:\` in Windows)
- **Home Directory:** `~` or `/home/username` is your personal folder
- **Current Directory:** `.` means "here" (current location)
- **Parent Directory:** `..` means "one level up"

## Navigation Commands

### `pwd` - Print Working Directory
**What it does:** Shows where you are in the file system  
**Example:**
```bash
pwd
# Output: /home/aadams
```
**Think of it as:** "Where am I?"

### `ls` - List Directory Contents
**Basic usage:** Shows files and folders in current directory
```bash
ls
# Output: file1.txt  documents  pictures
```

**Useful variations:**
```bash
ls -l          # Long format (shows permissions, size, date)
ls -la         # Long format + hidden files (starting with .)
ls -lh         # Long format + human readable sizes (KB, MB)
ls /etc        # List contents of /etc directory
```

### `cd` - Change Directory
**Basic usage:** Move to different folders
```bash
cd documents        # Go into documents folder
cd /home/aladdin    # Go to specific path
cd ..              # Go up one level
cd ~               # Go to home directory
cd /               # Go to root directory
cd                 # Go to home directory (same as cd ~)
```

## File Viewing Commands

### `cat` - Display File Contents
**What it does:** Shows entire file content at once  
**Best for:** Small files
```bash
cat filename.txt
cat /etc/passwd    # View system users
```

### `less` - View Large Files
**What it does:** Shows file content page by page  
**Best for:** Large files you need to scroll through
```bash
less filename.txt
# Navigation in less:
# Spacebar: Next page
# b: Previous page  
# q: Quit
# /search: Search for text
```

### `head` - Show First Lines
**What it does:** Shows beginning of file (default: first 10 lines)
```bash
head filename.txt
head -20 filename.txt    # Show first 20 lines
```

### `tail` - Show Last Lines  
**What it does:** Shows end of file (default: last 10 lines)
```bash
tail filename.txt
tail -20 filename.txt    # Show last 20 lines
tail -f logfile.txt      # Follow file changes (live updates)
```

## File Operations

### `cp` - Copy Files
**Basic usage:**
```bash
cp source.txt destination.txt        # Copy file
cp source.txt /home/user/backup/     # Copy to directory
cp -r folder1 folder2                # Copy directory recursively
```

### `mv` - Move/Rename Files
**Basic usage:**
```bash
mv oldname.txt newname.txt           # Rename file
mv file.txt /home/user/documents/    # Move file to directory
mv folder1 folder2                   # Rename directory
```

### `rm` - Remove Files
**⚠️ CAUTION: No "recycle bin" in Linux - files are permanently deleted!**
```bash
rm filename.txt          # Delete file
rm -r foldername        # Delete directory and contents
rm -f filename.txt      # Force delete (no confirmation)
rm *.txt               # Delete all .txt files
```

### `mkdir` - Create Directories
```bash
mkdir newfolder                    # Create single directory
mkdir -p path/to/nested/folders   # Create nested directories
```

## Text Search Commands

### `grep` - Search Inside Files
**What it does:** Finds lines containing specific text
```bash
grep "password" filename.txt           # Find lines with "password"
grep -i "password" filename.txt        # Case insensitive search
grep -r "password" /etc/               # Search recursively in directory
grep -n "error" logfile.txt            # Show line numbers
```

### `find` - Search for Files
**What it does:** Locates files and directories
```bash
find . -name "*.txt"                   # Find all .txt files
find /home -name "config"              # Find files named "config"
find . -type f -name "*.log"           # Find only files (not directories)
find . -size +100M                     # Find files larger than 100MB
```

## File Permissions

### Understanding `ls -l` Output
```bash
-rw-r--r-- 1 user group 1234 Mar 15 10:30 filename.txt
```
**Breakdown:**
- `-rw-r--r--`: Permissions (see below)
- `1`: Number of hard links
- `user`: Owner
- `group`: Group owner  
- `1234`: Size in bytes
- `Mar 15 10:30`: Last modified date/time
- `filename.txt`: File name

### Permission Format: `-rwxrwxrwx`
**Position 1:** File type (`-` = file, `d` = directory, `l` = link)  
**Positions 2-4:** Owner permissions (user)  
**Positions 5-7:** Group permissions  
**Positions 8-10:** Other permissions  

**Permission letters:**
- `r`: Read (can view file content)
- `w`: Write (can modify file)  
- `x`: Execute (can run file as program)
- `-`: Permission not granted

### `chmod` - Change Permissions
```bash
chmod 755 filename        # rwxr-xr-x (owner: full, others: read+execute)
chmod 644 filename        # rw-r--r-- (owner: read+write, others: read only)
chmod +x filename         # Add execute permission for everyone
chmod -w filename         # Remove write permission for everyone
```

## Process Management

### `ps` - Show Running Processes
```bash
ps                    # Show your processes
ps aux               # Show all processes (detailed)
ps aux | grep ssh    # Find SSH processes
```

### `top` - Live Process Monitor
```bash
top                  # Real-time process viewer (press q to quit)
htop                 # Enhanced version (if installed)
```

### `kill` - Stop Processes
```bash
kill 1234           # Stop process with ID 1234
kill -9 1234        # Force kill process
killall firefox     # Stop all Firefox processes
```

## Network Commands

### `ping` - Test Connectivity
```bash
ping google.com              # Test internet connection
ping 192.168.1.1            # Test local network
ping -c 4 google.com        # Send only 4 pings
```

### `wget` - Download Files
```bash
wget http://example.com/file.txt        # Download file
wget -O newname.txt http://site.com/file # Download with different name
```

### `curl` - Web Requests
```bash
curl http://example.com                 # View webpage
curl -o file.html http://example.com    # Save webpage to file
```

## System Information

### `whoami` - Current User
```bash
whoami
# Output: aadams
```

### `id` - User Details
```bash
id
# Output: uid=1001(aadams) gid=1001(aadams) groups=1001(aladmin),27(sudo)
```

### `uname` - System Information
```bash
uname -a        # All system information
uname -r        # Kernel version
```

### `df` - Disk Space
```bash
df -h           # Show disk usage in human-readable format
```

### `free` - Memory Usage
```bash
free -h         # Show memory usage in human-readable format
```

## Text Editing

### `nano` - Simple Text Editor
**Best for beginners:**
```bash
nano filename.txt
```
**Basic controls:**
- Type normally to edit
- `Ctrl+O`: Save file
- `Ctrl+X`: Exit
- `Ctrl+W`: Search
- `Ctrl+K`: Cut line
- `Ctrl+U`: Paste line

## Command History and Shortcuts

### Command History
```bash
history              # Show command history
!!                  # Repeat last command
!n                  # Repeat command number n from history
!ping               # Repeat last command starting with "ping"
```

### Keyboard Shortcuts
- `Ctrl+C`: Cancel current command
- `Ctrl+D`: Exit current shell/logout
- `Ctrl+L`: Clear screen (same as `clear` command)
- `Ctrl+A`: Move cursor to beginning of line
- `Ctrl+E`: Move cursor to end of line
- `Tab`: Auto-complete file/command names
- `Up Arrow`: Previous command
- `Down Arrow`: Next command

## Pipes and Redirection

### Pipes (`|`) - Chain Commands
```bash
ls -la | grep ".txt"              # List files, then filter for .txt files
cat /etc/passwd | wc -l           # Count lines in passwd file
ps aux | grep firefox             # Find Firefox processes
```

### Output Redirection
```bash
ls > filelist.txt                 # Save ls output to file (overwrite)
ls >> filelist.txt                # Append ls output to file
command 2> errors.txt             # Save error messages to file
command > output.txt 2>&1         # Save both output and errors
```

## Getting Help

### `man` - Manual Pages
```bash
man ls              # Show manual for ls command
man grep            # Show manual for grep command
# Navigation in man pages:
# Spacebar: Next page
# b: Previous page
# q: Quit
# /search: Search for text
```

### `--help` Flag
```bash
ls --help           # Show help for ls command
grep --help         # Show help for grep command
```

### `which` - Find Command Location
```bash
which python        # Show where python command is located
which nmap          # Show where nmap is installed
```

## Common File Locations

### Important Directories
- `/home/username`: User home directories
- `/etc/`: System configuration files
- `/var/log/`: System log files
- `/tmp/`: Temporary files
- `/usr/bin/`: User programs
- `/root/`: Root user's home directory

### Configuration Files
- `/etc/passwd`: User account information
- `/etc/shadow`: Encrypted passwords
- `/etc/hosts`: Local DNS entries
- `/etc/ssh/sshd_config`: SSH server configuration

## Tips for Beginners

1. **Use Tab completion:** Start typing a command or filename and press Tab
2. **Read error messages:** They usually tell you exactly what's wrong
3. **Start with `ls` and `pwd`:** Always know where you are and what's there
4. **Be careful with `rm`:** There's no undo - double-check before deleting
5. **Use `man` pages:** They contain comprehensive help for every command
6. **Practice in safe environment:** Use this lab to experiment without fear

## Lab-Specific Tips

### In the Attacker Container
```bash
# You start here when you enter the container
pwd                    # Should show: /root

# Lab files are mounted here
ls /root/lab          # Your downloaded files from attacks
ls /root/tools        # Attack scripts (recon.sh, exploit.sh)

# Navigate around safely
cd /root/lab          # Go to lab directory
ls -la                # See what files you've gathered
```

### Useful Lab Commands
```bash
# Check what tools are installed
which nmap hydra ftp ssh

# See running processes
ps aux | grep ssh     # Check if SSH is running

# Monitor network connections
netstat -tuln         # Show listening ports

# Check system information
cat /etc/os-release   # See what Linux distribution this is
```

Remember: This lab environment is safe to experiment in - you can't break anything permanent!