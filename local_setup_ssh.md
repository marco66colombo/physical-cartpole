# Recommended Setup for hls4ml Cartpole demo

 
Due to the complexity of the directory structure and the number of files involved in these experiments, it is **strongly recommended to set up both a remote development environment and a graphical user interface (GUI)**.  
You will need:
- **VS Code Remote - SSH** to write, edit, and run scripts.
- **GUI access** (via VNC) to use graphical tools like **Vivado**, **Vitis**, and a **CartPole simulator**.

---

## Step 1: Set Up Development Environment with VS Code

### Edit Your SSH Config

#### On macOS/Linux:

```bash
nano ~/.ssh/config
```

#### On Windows:

Open this file in Notepad or VS Code:

```
C:\Users\<YourUsername>\.ssh\config
```

Add this block:

```
Host hls4ml-workshop
    HostName 129.219.30.13
    User asuad\yourASU_ID
    ForwardX11 yes
    ForwardX11Trusted yes
```

Replace `yourASU_ID` with your actual ASU NetID.

You can now SSH with:

```bash
ssh hls4ml-workshop
```

and it will also be available as a host in VS Code.

### Connect via VS Code

1. Open **VS Code**
2. Press `F1` or `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
3. Type: `Remote-SSH: Connect to Host...`
4. Choose: `hls4ml-workshop`

---

## Step 2: Set Up GUI Access via RealVNC Viewer

To run **Vivado**, **Vitis**, and the **CartPole simulator**, a GUI is required. Use **RealVNC Viewer** for remote graphical access.

### Install RealVNC Viewer

- Visit: https://www.realvnc.com/en/connect/download/viewer/
- Download and install the viewer for your OS.

### Start a VNC Session on the Server

SSH into the server and run:

```bash
vncserver-virtual
```

This starts a GUI session and prints a display port (e.g., `:1`, `:2`, etc.).

### Connect from RealVNC Viewer

1. Open the **RealVNC Viewer** application.
2. Enter the address:

```
129.219.30.13:<port>
```

Replace `<port>` with the number from the `vncserver-virtual` output.

3. When prompted:
   - **Username:** `asuad\yourASU_ID`
   - **Password:** Your ASU password
