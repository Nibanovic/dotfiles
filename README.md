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

## TODO
- add install script
- add firacode font install automatic
- add RosTeamWorkspace setup automatic
