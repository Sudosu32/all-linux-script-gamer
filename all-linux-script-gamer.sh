
#!/bin/bash

# Função para verificar se o Flatpak está instalado
check_flatpak() {
  if ! command -v flatpak &> /dev/null
  then
    echo "Flatpak não encontrado! Instalando..."
    # Instalar Flatpak
    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install flatpak -y
    elif [ -f /etc/fedora-release ]; then
        sudo dnf install flatpak -y
    elif [ -f /etc/arch-release ]; then
        sudo pacman -S flatpak
    fi
  fi
}

# Função para adicionar o repositório Flathub
add_flathub_repo() {
  echo "Adicionando o repositório Flathub..."
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

# Função para instalar o pacote via Flatpak
install_flatpak() {
  package=$1
  echo "Deseja instalar $package? (s/n): "
  read -r install
  if [[ "$install" =~ ^[Ss]$ ]]; then
    sudo flatpak install flathub "$package" -y
  fi
}

# Função para verificar e instalar drivers específicos para cada GPU
check_and_install_driver() {
  gpu_choice=$1

  # Verifica se o driver da GPU já está instalado
  if [ "$gpu_choice" == "1" ]; then
    echo "Verificando driver para AMD..."
    if ! command -v amdgpu &> /dev/null; then
      echo "Driver AMD não encontrado. Instalando..."
      # Adicionar comando de instalação do driver AMD específico para a distribuição
      if [ -f /etc/debian_version ]; then
        sudo apt install xserver-xorg-video-amdgpu -y
      elif [ -f /etc/fedora-release ]; then
        sudo dnf install xorg-x11-drv-amdgpu -y
      elif [ -f /etc/arch-release ]; then
        sudo pacman -S xf86-video-amdgpu
      fi
    fi
  elif [ "$gpu_choice" == "2" ]; then
    echo "Verificando driver para NVIDIA..."
    if ! command -v nvidia-smi &> /dev/null; then
      echo "Driver NVIDIA não encontrado. Instalando..."
      # Adicionar comando de instalação do driver NVIDIA específico para a distribuição
      if [ -f /etc/debian_version ]; then
        sudo apt install nvidia-driver -y
      elif [ -f /etc/fedora-release ]; then
        sudo dnf install akmod-nvidia -y
      elif [ -f /etc/arch-release ]; then
        sudo pacman -S nvidia
      fi
    fi
  elif [ "$gpu_choice" == "3" ]; then
    echo "Verificando driver para Intel HD Graphics..."
    if ! command -v intel_gpu_tools &> /dev/null; then
      echo "Driver Intel HD Graphics não encontrado. Instalando..."
      # Adicionar comando de instalação do driver Intel
      if [ -f /etc/debian_version ]; then
        sudo apt install intel-gpu-tools -y
      elif [ -f /etc/fedora-release ]; then
        sudo dnf install intel-gpu-tools -y
      elif [ -f /etc/arch-release ]; then
        sudo pacman -S intel-gpu-tools
      fi
    fi
  fi
}

# Função para configurar a GPU e otimizações específicas
configure_gpu() {
  echo "Escolha sua GPU:"
  echo "1 - AMD"
  echo "2 - NVIDIA"
  echo "3 - Intel (Integrada)"
  read -p "Digite o número correspondente: " gpu_choice
  check_and_install_driver "$gpu_choice"

  if [ "$gpu_choice" == "1" ]; then
    echo "Configurando otimizações para AMD..."
    echo "Comandos para otimizar jogos na Steam:"
    echo "Para ativar MangoHud em um jogo, adicione no 'Opções de Inicialização' da Steam:"
    echo "MANGOHUD=1 gamemoderun %command%"
    echo "Comando para ativar o Vulkan Async (apenas AMD):"
    echo "RADV_PERFTEST=aco %command%"
  elif [ "$gpu_choice" == "2" ]; then
    echo "Configurando otimizações para NVIDIA..."
    echo "Comando para otimizar DXVK para NVIDIA:"
    echo "DXVK_ASYNC=1 __GL_SHADER_DISK_CACHE=1 %command%"
    echo "Comando para ativar o Vulkan Async (apenas NVIDIA):"
    echo "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json %command%"
    echo "Comando para ativar o NVIDIA Profile (controle de desempenho do driver):"
    echo "NVIDIA_DRIVER_CAPABILITIES=all %command%"
  elif [ "$gpu_choice" == "3" ]; then
    echo "Configurando otimizações para Intel..."
    echo "Comando para ativar o Vulkan Async (apenas Intel):"
    echo "INTEL_MAX_MEM_QUEUES=4 %command%"
    echo "Comando para melhorar o desempenho de jogos no Steam com placas Intel:"
    echo "LIBGL_ALWAYS_SOFTWARE=1 MESA_LOADER_DRIVER_OVERRIDE=i965 %command%"
    echo "Comando para melhorar o desempenho com gráficos Intel, use o comando abaixo na Steam:"
    echo "MANGOHUD=1 gamemoderun %command%"
  else
    echo "Opção inválida. Nenhuma configuração aplicada."
  fi
}

# Função principal do script
main() {
  echo "Atualizando e carregando repositórios..."
  sudo flatpak update -y

  # Verifica e instala o Flatpak
  check_flatpak

  # Adiciona o repositório Flathub
  add_flathub_repo

  # Instala os jogos e ferramentas necessários
  install_flatpak com.valvesoftware.Steam
  install_flatpak net.lutris.Lutris
  install_flatpak com.heroicgameslauncher.hgl
  install_flatpak com.github.Matoking.protontricks
  install_flatpak org.freedesktop.Platform.VulkanLayer.MangoHud
  install_flatpak net.rpcs3.RPCS3
  install_flatpak io.mgba.mGBA
  install_flatpak org.ppsspp.PPSSPP
  install_flatpak net.pcsx2.PCSX2
  install_flatpak org.duckstation.DuckStation
  install_flatpak io.github.hmlendea.geforcenow-electron
  install_flatpak io.github.antimicrox.antimicrox

  # Instalar o GameMode
  echo "Instalando o GameMode..."
  if [ -f /etc/debian_version ]; then
    sudo apt install gamemode -y
  elif [ -f /etc/fedora-release ]; then
    sudo dnf install gamemode -y
  elif [ -f /etc/arch-release ]; then
    sudo pacman -S gamemode
  fi

  # Pergunta sobre a configuração da GPU
  configure_gpu

  echo "Configuração finalizada! Reinicie o sistema para aplicar todas as otimizações."

  # Mensagem de incentivo ao canal
  echo "Gostou do script? Passe no meu canal do YouTube e ajude a criar mais conteúdos!"
  echo "Se inscreva, curta os vídeos, comente e compartilhe para me incentivar!"
  echo "Canal: https://www.youtube.com/@neotrixsu"
}

# Chama a função principal
main
