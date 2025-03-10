#!/bin/bash

# Clear screen before starting
clear

# Define colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
NC='\e[0m' # No Color

# Function to show menu
echo_menu() {
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
    echo -e "${BLUE}0) Exit${NC}"
    echo -ne "${CYAN}Enter your choice: ${NC}"
}

while true; do
    echo_menu
    read choice
    case "$choice" in
        1)
            echo -e "${GREEN}Listing all running Docker containers...${NC}"
            docker ps
            ;;
        2)
            echo -e "${GREEN}Listing all stopped Docker containers...${NC}"
            docker ps -a --filter "status=exited"
            ;;
        3)
            echo -e "${GREEN}Listing all Docker volumes...${NC}"
            docker volume ls
            ;;
        4)
            echo -e "${YELLOW}Starting all Docker containers...${NC}"
            docker start $(docker ps -aq)
            ;;
        5)
            echo -e "${YELLOW}Stopping all Docker containers...${NC}"
            docker stop $(docker ps -q)
            ;;
        6)
            echo -e "${YELLOW}Restarting all Docker containers...${NC}"
            docker restart $(docker ps -q)
            ;;
        7)
            if [ -n "$(docker ps -aq)" ]; then
                echo -e "${RED}Removing all stopped containers...${NC}"
                docker rm $(docker ps -aq)
            else
                echo -e "${CYAN}No stopped containers to remove.${NC}"
            fi
            ;;
        8)
            if [ -n "$(docker volume ls -q)" ]; then
                echo -e "${RED}Removing all unused Docker volumes...${NC}"
                docker volume prune -f
            else
                echo -e "${CYAN}No unused volumes to remove.${NC}"
            fi
            ;;
        9)
            if [ -n "$(docker images -q -f "dangling=true")" ]; then
                echo -e "${RED}Removing unused Docker images...${NC}"
                docker image prune -af
            else
                echo -e "${CYAN}No unused images to remove.${NC}"
            fi
            ;;
        10)
            echo -e "${RED}Pruning entire Docker system (containers, networks, images, build cache)...${NC}"
            docker system prune -af
            ;;
        11)
            echo -e "${YELLOW}Checking current SELinux status...${NC}"
            sestatus
            echo -e "${YELLOW}Setting SELinux to permissive mode...${NC}"
            setenforce 0
            echo -e "${YELLOW}Confirming updated SELinux status...${NC}"
            sestatus
            echo -e "${YELLOW}Restarting Nginx service...${NC}"
            systemctl restart nginx
            echo -e "${YELLOW}Rebooting system...${NC}"
            reboot
            ;;
        0)
            echo -e "${BLUE}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
    echo ""
done
