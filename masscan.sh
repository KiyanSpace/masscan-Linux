#!/bin/bash
clear
echo "                        _____  _____  _____  "
echo "                       |  __ \\|  __ \\|  __ \\ "
echo "  ___  _ __   ___ _ __ | |__) | |  | | |__) |"
echo " / _ \\| '_ \\ / _ \\ '_ \\|  _  /| |  | |  ___/ "
echo "| (_) | |_) |  __/ | | | | \\ \\| |__| | |     "
echo " \\___/| .__/ \\___|_| |_|_|  \\_\\_____/|_|     "
echo "      | |                                    "
echo "      |_|                                    "
echo "--------------------------------------------------"
echo "Contact: t.me/openrdp"
echo "--------------------------------------------------"

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
echo "PORT:"
read -r PORT
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    echo "Invalid PORT"
    exit 1
fi

echo "RANGE IP: "
read -r INPUT_FILE
if [ ! -f "$INPUT_FILE" ]; then
    echo "NOT FILE $INPUT_FILE"
    exit 1
fi

echo "RATE:"
read -r RATE
masscan --exclude 255.255.255.255 -p "$PORT" -iL "$INPUT_FILE" -oL IPs.txt --rate="$RATE"
echo "SAVED File"
echo "Enter output filename (example IP.txt)"
read -r OUTPUT_FILE
awk '{print $4 ":" $3}' IPs.txt > "$OUTPUT_FILE"
echo "Data saved to $OUTPUT_FILE"
echo "Do you want to send the file $OUTPUT_FILE to Telegram? (yes/no)"
read -r SEND_TO_TELEGRAM
if [[ "$SEND_TO_TELEGRAM" == "yes" ]]; then
    echo "Enter your Telegram Bot Token:"
    read -r TELEGRAM_TOKEN
    echo "Enter your Telegram Chat ID:"
    read -r CHAT_ID

    # ارسال فایل به تلگرام
    curl -s -X POST https://api.telegram.org/bot"$TELEGRAM_TOKEN"/sendDocument -F chat_id="$CHAT_ID" -F document=@"$OUTPUT_FILE"

    echo "File sent to Telegram successfully."
else
    echo "Operation completed. The file $OUTPUT_FILE saved"
fi
