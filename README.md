# vim-nodegf
[![Build Status](https://travis-ci.org/oesse/vim-nodegf.svg?branch=master)](https://travis-ci.org/oesse/vim-nodegf)

Use `gf` on JavaScript import/require statement to go to the imported file.

### Installation

Requirements:
* Vim 8 or NeoVim v0.2.0

###### with [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'oesse/vim-nodegf'
```
###### with [pathogen](https://github.com/tpope/vim-pathogen)
```sh
cd ~/.vim/bundle
git clone git://github.com/oesse/vim-nodegf.git
```
### Why?

I know of [Node.vim](https://github.com/moll/vim-node) which contains similar functionality and more, as well as [vim-javascript-gf.vim](https://github.com/feix760/vim-javascript-gf) which does basically the same thing.

Node.vim includes features I personally do not use and I found the resolution mechanism to not always work. Also file paths are resolved with "." and ".." links still present, which I don't like, e.g. `require('./foo/bar')` when in file `project-root/baz` would open the correct file as `project-root/baz/./foo/bar`.

vim-javascript-gf.vim uses the npm module [require-relative](https://www.npmjs.com/package/require-relative) to resolve paths and I found it after I wrote this plugin.

This plugin is 100% vimscript, is unit tested, has no dependencies, and I tried to keep it very small.
