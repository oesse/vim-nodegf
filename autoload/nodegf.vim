let s:nodegf_file_exts = [".js", ".jsx", ".coffee"]

function! nodegf#GoToNodeModule()
  let pathname = s:GetImportedFilePath()
  " no path to follow found
  if empty(pathname)
    " fallback to default behaviour
    normal! gf
    return
  endif

  let filename = s:GetSourceFilename(pathname)
  if filename == v:false
    echoerr "No import found"
    return
  endif

  if bufexists(filename)
    execute "buffer ".filename
    return
  endif

  execute "edit ".filename
endfunction

function! s:GetImportedFilePath()
  let save_cursor = getcurpos()
  let save_a = @a
  normal! 0
  if !search("['\"]", "", line('.'))
    return ''
  endif

  let quote = strpart(getline('.'), col('.') - 1, 1)
  execute 'normal! "ayi'.quote
  let result = @a
  let @a = save_a
  call setpos('.', save_cursor)
  return result
endfunction

function! s:GetSourceFilename(pathname)
  if strpart(a:pathname, 0, 1) ==# "."
    return s:GetLocalFilename(expand("%:h"), a:pathname)
  endif
  return s:GetNpmFilename(a:pathname)
endfunction

" dirname: directory to use as starting point for relative lookup
" pathname: path to resolve
function! s:GetLocalFilename(dirname, pathname)
  " resolve file imports
  let base = resolve(fnamemodify(a:dirname . "/" . a:pathname, ":~:."))
  let base_path = fnamemodify(base, ":h")
  let base_name = fnamemodify(base, ":t")
  let joined_exts = join(s:nodegf_file_exts, ",")
  let glob_pattern = base_name."{,".joined_exts.",/index{".joined_exts."}}"
  let globs = split(globpath(base_path, glob_pattern))

  " Remove directory from result list.
  if len(globs) > 0 && globs[0][-1:] ==# "/"
    let globs = globs[1:]
  end
  if len(globs) > 0
    return globs[0]
  endif
  return v:false
endfunction

function! s:GetNpmFilename(pathname)
  let npm_root = s:GetNpmRoot(expand("%:h"))
  let path = split(a:pathname, "/")
  let npm_module_path = resolve(npm_root . "/node_modules/" . path[0])
  if a:pathname =~# "/"
    return s:GetLocalFilename(npm_module_path, join(path[1:], "/"))
  endif

  let entry_point = json_decode(join(readfile(npm_module_path . "/package.json"))).main
  return s:GetLocalFilename(npm_module_path, entry_point)
endfunction

function! s:GetNpmRoot(pathname)
  let current_dir = a:pathname
  while current_dir !=# "/" && !filereadable(current_dir . "/package.json")
    let current_dir = resolve(current_dir . "/..")
  endwhile
  return current_dir
endfunction
