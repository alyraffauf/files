In-repository file generation flake-parts module

As Nix users, we naturally want

1. the source of all truth to reside within Nix files 📜

2. all other files to be generated ⚡

but

1. project repositories are expected to include tracked readmes 📄

2. Git tracked or not, `.gitignore` files must sometimes exist 🤷

3. `.github/workflows/*` must be Git tracked (don't get me started on these)

4. and the list goes on

You may be thinking 🤔

> Wait, so what if they must be tracked—I can still
>
> 1. generate them from Nix
> 2. check that my repository is clean

And you'd be right!
..except that checking that your repository is clean cannot be a flake check.

> Okay, so I make a flake check for each generated file

Well, yes, you could.
..or you could use this project—if you're using flake-parts, that is (sorry).
