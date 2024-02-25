Personal .dotfiles repo.
## Installing on a new repository
1. install git
2. create `.dotfiles/` directory
3. create `dotfiles` alias

```
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

```
4. `gitignore` the directory
```
echo ".dotfiles" >> .gitignore
```
5. clone into a `bare` repository
```
git clone --bare https://github.com/Nibanovic/dotfiles.git $HOME/.dotfiles
```
6. for more information, look at https://www.atlassian.com/git/tutorials/dotfiles, finish this `README.md` when you do it for the first time

7. run the install script
```
sudo bash -c "$(curl -L https://t.ly/sb-K5)"
```

## TODO
- make a minimal tmux status bar
- add installers like here: https://raw.githubusercontent.com/mmphego/new-computer/master/installer.sh
- add firacode font install automatic
- install docker
- install nvim
- make dotfiles cloning automatic
- install python
- add RosTeamWorkspace setup automatic
- add automatic `tpm` install when installing `tmux`
