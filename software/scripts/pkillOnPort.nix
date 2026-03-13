{pkgs, ...}:

pkgs.writeShellApplication {
  name = "pkill-port";
  runtimeInputs = [
    pkgs.lsof
  ];
  text = ''
    if [ "$#" -ne 1 ]; then
      echo "Usage: pkill-port <port>"
      exit 1
    fi

    PORT=$1
    
    if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
      echo "Error: port must be a number"
      exit 1
    fi

    PIDS=$(lsof -t -i :"$PORT" || true)

    if [ -z "$PIDS" ]; then
      echo "No process found on port $PORT"
      exit 0
    fi

    echo "Killing processes on port $PORT:"
    for pid in $PIDS; do
      echo "Killing $pid"
      kill -9 "$pid"
    done
  '';
}
