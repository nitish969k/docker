#!/bin/bash

# #clear screen before starting
clear

# Define colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
NC='\e[0m' # No Color

# Function to update script
update_script() {
    #clear
    echo -e "${YELLOW}Checking for script updates...${NC}"
    SCRIPT_PATH=$(realpath "$0")
    TEMP_SCRIPT="/tmp/docker_update.sh"

    # Fetch and hash the remote script
    curl -sL "https://raw.githubusercontent.com/nitish969k/docker/refs/heads/main/docker.sh" -o "$TEMP_SCRIPT"
    REMOTE_HASH=$(sha256sum "$TEMP_SCRIPT" | awk '{print $1}')
    LOCAL_HASH=$(sha256sum "$SCRIPT_PATH" | awk '{print $1}')

    if [ "$LOCAL_HASH" == "$REMOTE_HASH" ]; then
        echo -e "${GREEN}Script is already up to date.${NC}"
        rm -f "$TEMP_SCRIPT"
    else
        echo -e "${YELLOW}Updating script...${NC}"
        mv "$TEMP_SCRIPT" "$SCRIPT_PATH"
        chmod +x "$SCRIPT_PATH"
        echo -e "${GREEN}Script updated successfully. Restarting...${NC}"
        exec "$SCRIPT_PATH"
    fi
}

# Function to show menu
echo_menu() {
    #clear
    echo -e "${CYAN}Select an option:${NC}"
    echo -e "${GREEN}1) List all running containers${NC}"
    echo -e "${GREEN}2) List all stopped containers${NC}"
    echo -e "${GREEN}3) List all Docker volumes${NC}"
    echo -e "${YELLOW}4) Start all containers${NC}"
    echo -e "${YELLOW}5) Stop all running containers${NC}"
    echo -e "${YELLOW}6) Restart all running containers${NC}"
    echo -e "${RED}7) Remove all stopped containers${NC}"
    echo -e "${RED}8) Remove all unused Docker volumes${NC}"
    echo -e "${RED}9) Clean unused Docker images${NC}"
    echo -e "${RED}10) Prune entire Docker system${NC}"
    echo -e "${YELLOW}11) Reboot system & configure SELinux & restart Nginx${NC}"
    echo -e "${YELLOW}12) Update this script${NC}"
    echo -e "${BLUE}0) Exit${NC}"
    echo -ne "${CYAN}Enter your choice: ${NC}"
}

while true; do
    echo_menu
    read choice
    case "$choice" in
        1)
            #clear
            echo -e "${GREEN}Listing all running Docker containers...${NC}"
            docker ps
            ;;
        2)
            #clear
            echo -e "${GREEN}Listing all stopped Docker containers...${NC}"
            docker ps -a --filter "status=exited"
            ;;
        3)
            #clear
            echo -e "${GREEN}Listing all Docker volumes...${NC}"
            docker volume ls
            ;;
        4)
            #clear
            echo -e "${YELLOW}Starting all Docker containers...${NC}"
            docker start $(docker ps -aq)
            ;;
        5)
            #clear
            echo -e "${YELLOW}Stopping all Docker containers...${NC}"
            docker stop $(docker ps -q)
            ;;
        6)
            #clear
            echo -e "${YELLOW}Restarting all Docker containers...${NC}"
            docker restart $(docker ps -q)
            ;;
        7)
            #clear
            if [ -n "$(docker ps -aq)" ]; then
                echo -e "${RED}Removing all stopped containers...${NC}"
                #docker rm $(docker ps -aq)
                docker system prune -af
            else
                echo -e "${CYAN}No stopped containers to remove.${NC}"
            fi
            ;;
        8)
            #clear
            if [ -n "$(docker volume ls -q)" ]; then
                echo -e "${RED}Removing all unused Docker volumes...${NC}"
                docker volume prune -f
            else
                echo -e "${CYAN}No unused volumes to remove.${NC}"
            fi
            ;;
        9)
            #clear
            if [ -n "$(docker images -q -f "dangling=true")" ]; then
                echo -e "${RED}Removing unused Docker images...${NC}"
                docker image prune -af
            else
                echo -e "${CYAN}No unused images to remove.${NC}"
            fi
            ;;
        10)
            #clear
            echo -e "${RED}Pruning entire Docker system (containers, networks, images, build cache)...${NC}"
            docker system prune -af
            ;;
        11)
            #clear
            echo -e "${YELLOW}Checking current SELinux status...${NC}"
            sestatus
            echo -e "${YELLOW}Setting SELinux to permissive mode...${NC}"
            setenforce 0
            echo -e "${YELLOW}Confirming updated SELinux status...${NC}"
            sestatus
            echo -e "${YELLOW}Restarting Nginx service...${NC}"
            systemctl restart nginx
            echo -e "${YELLOW}Rebooting system...${NC}"
            #reboot
            ;;
        12)
            update_script
            ;;
        0)
            #clear
            echo -e "${BLUE}Exiting...${NC}"
            exit 0
            ;;
        *)
            #clear
            echo -e "${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
    echo ""
done