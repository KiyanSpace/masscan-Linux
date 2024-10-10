#!/bin/bash
clear
cat << "EOF"
                        _____  _____  _____  
                       |  __ \|  __ \|  __ \ 
  ___  _ __   ___ _ __ | |__) | |  | | |__) |
 / _ \| '_ \ / _ \ '_ \|  _  /| |  | |  ___/ 
| (_) | |_) |  __/ | | | | \ \| |__| | |     
 \___/| .__/ \___|_| |_|_|  \_\_____/|_|     
      | |                                   
      |_|                                   
--------------------------------------------------
Contact: t.me/openrdp
--------------------------------------------------
EOF

# Check if masscan is installed, and install it if necessary
if ! command -v masscan &> /dev/null; then
    echo "masscan is not installed."
    echo "Installing masscan from GitHub..."
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y git gcc make
    elif command -v yum &> /dev/null; then
        sudo yum install -y git gcc make
    else
        echo "Unsupported package manager. Please install Git, GCC, and Make manually."
        exit 1
    fi
    git clone https://github.com/robertdavidgraham/masscan.git
    cd masscan || exit 1
    make
    sudo cp bin/masscan /usr/local/bin/
    cd .. || exit 1
    rm -rf masscan

    echo "masscan has been installed."
else
    echo "masscan is already installed."
fi

echo "Masscan Scanner"

while true; do
    read -r -p "PORT : " PORT

    if [[ "$PORT" =~ ^([0-9]+(,[0-9]+)*|[0-9]+(-[0-9]+)(,[0-9]+(-[0-9]+)*)*)$ ]]; then
        break
    else
        echo "Invalid PORT input. Please try again."
    fi
done
while true; do
    read -r -p "RANGE IP " INPUT_FILE
    if [[ -f "$INPUT_FILE" ]]; then
        break
    else
        echo "Not a valid file: $INPUT_FILE. Please provide a valid file."
    fi
done


read -r -p "RATE: " RATE
masscan --exclude 255.255.255.255 -p "$PORT" -iL "$INPUT_FILE" -oL IPs.txt --rate="$RATE" 
echo "Saved file: IPs.txt"
read -r -p "Enter output filename (example IP.txt): " OUTPUT_FILE
awk '{print $4 ":" $3}' IPs.txt > "$OUTPUT_FILE"
echo "Data saved to $OUTPUT_FILE"
read -r -p "Do you want to send the file $OUTPUT_FILE to Telegram? (yes/no): " SEND_TO_TELEGRAM
if [[ "$SEND_TO_TELEGRAM" == "yes" ]]; then
    read -r -p "Enter your Telegram Bot Token: " TELEGRAM_TOKEN
    read -r -p "Enter your Telegram Chat ID: " CHAT_ID
    curl -s -X POST https://api.telegram.org/bot"$TELEGRAM_TOKEN"/sendDocument -F chat_id="$CHAT_ID" -F document=@"$OUTPUT_FILE"

    echo "File sent to Telegram successfully."
else
    echo "Operation completed. The file $OUTPUT_FILE has been saved."
fi
