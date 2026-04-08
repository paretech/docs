# Mac Terminal Setup

- Install homebrew. Yes, it is now safe to use on Arm macs…
- Install iTerm2 (either via pkg installer or homebrew)
  - Set profile theme to solarized
  - Disable tick marks
    - You can hide these marks in iTerm2 preferences: Profiles -> Open Profiles -> Edit Profiles -> Select your profile -> Terminal -> Uncheck "Show mark indicators".
- Install OhMyZsh. I don't like to use the curl lazy install method. Download the repo and do a Manual Install
  - Enable plugins (i.e. edit .zshrc)
    - Git
    - Z
  - Styling
    - Also, beware that themes only control what your prompt looks like. This is, the text you see before or after your cursor, where you'll type your commands. Themes don't control things such as the colors of your terminal window (known as color scheme) or the font of your terminal. These are settings that you can change in your terminal emulator.
    - <https://blog.larsbehrenberg.com/the-definitive-iterm2-and-oh-my-zsh-setup-on-macos?source=more_series_bottom_blogs>
    - Prompt
      - Starship
      - <https://github.com/romkatv/powerlevel10k> (tring April 2025)
          ® Run `p10k configure`
          ® Classic or Rainbow
    - Fonts
      - Nerd Font
      - Powerline
      - MesloLGS Nerd Font (p10k default)
      - JetBrainsMono Nerd Font
    - Color Schemes
      - Soloarized (iTerm native)
      - <https://github.com/MartinSeeler/iterm2-material-design>
      - <https://iterm2colorschemes.com/>
      - Dracula, Catppuccin, or Tokyo Night

- Create shortcuts to SublimeText
  - <https://www.sublimetext.com/docs/command_line.html>
    - To use subl, the Sublime Text bin folder needs to be added to the path.
      - Execute following from zsh shell, `echo 'export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"' >> ~/.zprofile`
    - To use Sublime Text as the editor for many commands that prompt for input, set your EDITOR environment variable:
      - Execute following from zsh shell, `echo 'export EDITOR="subl -w"' >> ~/.zprofile`
  - <https://stackoverflow.com/questions/16199581/open-sublime-text-from-terminal-in-macos>
- Create shortcuts (i.e. terminal integrations) for VS Code
  - <https://code.visualstudio.com/docs/setup/mac>
  - To run VS Code from the terminal by typing code, add it the $PATH environment variable
