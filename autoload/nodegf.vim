let s:nodegf_file_exts = [".js", ".jsx", ".coffee"]

function! nodegf#GoToNodeModule()
  let pathname = nodegf#GetImportedFilePath()
  " no path to follow found
  if empty(pathname)
    " fallback to default behaviour
    normal! gf
    return
  endif

  let filename = nodegf#GetSourceFilename(expand("%:h"), pathname)
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

function! nodegf#GetImportedFilePath()
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

function! nodegf#GetSourceFilename(cwd, pathname)
  if strpart(a:pathname, 0, 1) ==# "."
    return s:GetLocalFilename(a:cwd, a:pathname)
  endif
  return s:GetNpmFilename(a:cwd, a:pathname)
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
  let globs = globpath(base_path, glob_pattern, v:true, v:true)

  " Remove directory from result list.
  if len(globs) > 0 && globs[0][-1:] ==# "/"
    let globs = globs[1:]
  end
  if len(globs) > 0
    return globs[0]
  endif
  return v:false
endfunction

function! s:GetNpmFilename(cwd, pathname)
  let path = split(a:pathname, "/")
  let module_dir = s:GetModuleDir(a:cwd, path[0])
  if a:pathname =~# "/"
    return s:GetLocalFilename(module_dir, join(path[1:], "/"))
  endif

  let entry_point = json_decode(join(readfile(module_dir . "/package.json"))).main
  return s:GetLocalFilename(module_dir, entry_point)
endfunction

function! s:GetModuleDir(pathname, module)
  let current_dir = a:pathname
  while current_dir !=# "/"
    let candidate = current_dir . "/node_modules/" . a:module
    if isdirectory(candidate)
      return candidate
    endif
    let current_dir = resolve(fnamemodify(current_dir . "/..", ":p"))
  endwhile
  if current_dir ==# "/" && !isdirectory("/node_modules/" . a:module)
    throw "'" . a:module . "' is not installed."
  end
  return current_dir
endfunction
