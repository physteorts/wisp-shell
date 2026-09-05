pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.configs

Singleton {
    id: service

    property string currentTime: ""
    property string currentDate: ""
    property string statusMessage: ""
    property bool isAuthenticating: false
    property var availableSessions: [
        {
            name: "Niri",
            cmd: "niri-session"
        },
        {
            name: "Sway",
            cmd: "sway"
        },
        {
            name: "Bash",
            cmd: "bash"
        }
    ]
    property int selectedSessionIndex: 0
    readonly property string defaultUsername: Config.targetUser

    readonly property string greetdSocket: Quickshell.env("GREETD_SOCK") || "/run/greetd.sock"
    readonly property bool isLiveGreetd: Quickshell.env("GREETD_SOCK") !== undefined

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const date = new Date();
            service.currentTime = Qt.formatTime(date, "hh:mm");
            service.currentDate = Qt.formatDateTime(date, "dddd, MMMM d");
        }
    }

    Process {
        id: authProc
        property string stdoutBuffer: ""

        stdout: SplitParser {
            onRead: data => {
                authProc.stdoutBuffer += data;
            }
        }

        onExited: (code, status) => {
            service.isAuthenticating = false;
            const output = authProc.stdoutBuffer.trim();
            authProc.stdoutBuffer = "";

            if (code === 0) {
                service.statusMessage = "Authenticated. Launching session...";
            } else {
                service.statusMessage = output || "Authentication failed";
            }
        }
    }

    function login(username: string, secret: string): void {
        if (!username || !secret || isAuthenticating)
            return;

        if (!isLiveGreetd) {
            service.statusMessage = "greetd is not running; start the greeter through greetd";
            return;
        }

        isAuthenticating = true;
        service.statusMessage = "Authenticating...";

        const sessionCmd = availableSessions[selectedSessionIndex].cmd;

        // Python helper talking JSON directly over GREETD_SOCK
        const pyAuthScript = `
import os, sys, socket, json, struct

sock_path = sys.argv[-1] if len(sys.argv) > 1 else os.environ.get("GREETD_SOCK")
if not sock_path:
    print("GREETD_SOCK not set")
    sys.exit(1)

def send_msg(s, obj):
    body = json.dumps(obj).encode("utf-8")
    s.sendall(struct.pack("=I", len(body)) + body)

def recv_msg(s):
    hdr = s.recv(4)
    if not hdr or len(hdr) < 4:
        return None
    length = struct.unpack("=I", hdr)[0]
    payload = b""
    while len(payload) < length:
        chunk = s.recv(length - len(payload))
        if not chunk:
            break
        payload += chunk
    return json.loads(payload.decode("utf-8"))

try:
    client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    client.settimeout(15)
    client.connect(sock_path)

    # 1. Start Session
    send_msg(client, {"type": "create_session", "username": sys.argv[-4]})
    resp = recv_msg(client)

    # 2. Answer prompt / auth challenge
    while resp and resp.get("type") == "auth_message":
        send_msg(client, {"type": "post_auth_message_response", "response": sys.argv[-3]})
        resp = recv_msg(client)

    # 3. Start user desktop
    if resp and resp.get("type") == "success":
        cmd = [sys.argv[-2]]
        send_msg(client, {"type": "start_session", "cmd": cmd, "env": []})
        final_resp = recv_msg(client)
        if final_resp and final_resp.get("type") == "success":
            sys.exit(0)
        else:
            print(final_resp.get("description", "Failed to start session"))
            sys.exit(1)
    else:
        err = resp.get("description", "Authentication failure") if resp else "Empty daemon response"
        print(err)
        sys.exit(1)
except FileNotFoundError:
    print("greetd socket not found: " + sock_path)
    sys.exit(1)
except Exception as e:
    print(str(e))
    sys.exit(1)
`;

        authProc.command = ["python3", "-c", pyAuthScript, username, secret, sessionCmd, greetdSocket];
        authProc.running = true;
    }

    function powerOff(): void {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    function reboot(): void {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function suspend(): void {
        Quickshell.execDetached(["systemctl", "suspend"]);
    }
}
